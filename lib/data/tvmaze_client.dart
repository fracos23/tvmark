import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../domain/enums.dart';
import 'app_database.dart';

/// Errore restituito dal client TVmaze.
class TvmazeException implements Exception {
  TvmazeException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// 429: superato il limite di ~20 chiamate ogni 10 secondi.
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => 'TvmazeException($statusCode): $message';
}

/// Risultato di ricerca: NON viene salvato nel database finché
/// l'utente non sceglie di seguire la serie.
class ShowSearchResult {
  const ShowSearchResult({
    required this.id,
    required this.name,
    required this.status,
    this.imageUrl,
    this.network,
    this.premieredYear,
  });

  final int id;
  final String name;
  final ShowStatus status;
  final String? imageUrl;
  final String? network;
  final int? premieredYear;
}

/// Serie + episodi pronti per essere scritti nel database.
class ShowWithEpisodes {
  const ShowWithEpisodes({required this.show, required this.episodes});

  final TvShowsCompanion show;
  final List<EpisodesCompanion> episodes;
}

/// Client minimale per l'API pubblica di TVmaze (https://www.tvmaze.com/api).
/// Nessuna API key. Dati sotto licenza CC BY-SA.
class TvmazeClient {
  /// [client] si può sostituire nei test con un MockClient.
  TvmazeClient({http.Client? client}) : _client = client ?? http.Client();

  static const _host = 'api.tvmaze.com';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// GET /search/shows?q=...
  Future<List<ShowSearchResult>> searchShows(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final json = await _get('/search/shows', {'q': q}) as List<dynamic>;
    return json
        .map((item) => parseSearchResult(
            (item as Map<String, dynamic>)['show'] as Map<String, dynamic>))
        .toList();
  }

  /// GET /shows/{id}?embed=episodes — serie ed episodi in una sola chiamata.
  Future<ShowWithEpisodes> fetchShowWithEpisodes(int showId) async {
    final json =
        await _get('/shows/$showId', {'embed': 'episodes'}) as Map<String, dynamic>;
    return parseShowWithEpisodes(json);
  }

  void close() => _client.close();

  Future<dynamic> _get(String path, Map<String, String> params) async {
    final uri = Uri.https(_host, path, params);
    final http.Response res;
    try {
      res = await _client.get(uri).timeout(_timeout);
    } on Exception catch (e) {
      throw TvmazeException('Errore di rete: $e');
    }

    if (res.statusCode == 429) {
      throw TvmazeException('Troppe richieste, riprova tra poco',
          statusCode: 429);
    }
    if (res.statusCode == 404) {
      throw TvmazeException('Serie non trovata', statusCode: 404);
    }
    if (res.statusCode != 200) {
      throw TvmazeException('Risposta inattesa', statusCode: res.statusCode);
    }
    // bodyBytes + utf8: evita problemi con caratteri accentati nei titoli.
    return jsonDecode(utf8.decode(res.bodyBytes));
  }
}

// ---------------------------------------------------------------------------
// Parsing JSON -> modelli. Funzioni pure, testabili senza rete.
// ---------------------------------------------------------------------------

String? _networkName(Map<String, dynamic> show) {
  // Le serie TV hanno "network", quelle streaming "webChannel".
  final network = show['network'] as Map<String, dynamic>?;
  final web = show['webChannel'] as Map<String, dynamic>?;
  return (network?['name'] ?? web?['name']) as String?;
}

String? _imageUrl(Map<String, dynamic> show) {
  final image = show['image'] as Map<String, dynamic>?;
  return image?['medium'] as String?;
}

/// "2011-04-18T01:00:00+00:00" -> DateTime UTC. Null o stringa vuota -> null.
DateTime? parseAirstamp(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}

ShowSearchResult parseSearchResult(Map<String, dynamic> show) {
  final premiered = show['premiered'] as String?;
  return ShowSearchResult(
    id: show['id'] as int,
    name: show['name'] as String,
    status: ShowStatus.fromTvmaze(show['status'] as String?),
    imageUrl: _imageUrl(show),
    network: _networkName(show),
    premieredYear: premiered == null || premiered.length < 4
        ? null
        : int.tryParse(premiered.substring(0, 4)),
  );
}

EpisodesCompanion parseEpisode(Map<String, dynamic> ep, int showId) {
  return EpisodesCompanion.insert(
    id: Value(ep['id'] as int),
    showId: showId,
    season: ep['season'] as int,
    number: Value(ep['number'] as int?),
    name: (ep['name'] as String?) ?? 'Episodio senza titolo',
    airstamp: Value(parseAirstamp(ep['airstamp'])),
    runtime: Value(ep['runtime'] as int?),
  );
}

ShowWithEpisodes parseShowWithEpisodes(Map<String, dynamic> json) {
  final showId = json['id'] as int;
  final show = TvShowsCompanion.insert(
    id: Value(showId),
    name: json['name'] as String,
    status: ShowStatus.fromTvmaze(json['status'] as String?),
    imageUrl: Value(_imageUrl(json)),
    network: Value(_networkName(json)),
    tvmazeUpdated: Value(json['updated'] as int?),
  );

  final embedded = json['_embedded'] as Map<String, dynamic>?;
  final rawEpisodes = (embedded?['episodes'] as List<dynamic>?) ?? const [];
  final episodes = rawEpisodes
      .map((e) => parseEpisode(e as Map<String, dynamic>, showId))
      .toList();

  return ShowWithEpisodes(show: show, episodes: episodes);
}
