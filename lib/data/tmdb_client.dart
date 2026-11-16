import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;

import '../domain/enums.dart';
import 'app_database.dart';
import 'show_models.dart';

/// Errore restituito dal client TMDB.
class TmdbException extends ApiException {
  TmdbException(super.message, {super.statusCode});
}

/// Client minimale per l'API di TMDB (https://developer.themoviedb.org).
/// Usato come fonte secondaria, per le serie che TVmaze non ha
/// (soprattutto TV italiana). Richiede una chiave gratuita.
///
/// Questo prodotto usa l'API TMDB ma non è approvato né certificato da TMDB.
class TmdbClient {
  /// [credential] può essere:
  /// - l'"API Read Access Token" (v4, lungo): inviato come Bearer;
  /// - la "API Key" (v3, 32 caratteri): inviata come parametro api_key.
  /// Se è vuota il client è disattivato ([isConfigured] = false).
  TmdbClient({required String credential, http.Client? client})
      : _credential = credential.trim(),
        _client = client ?? http.Client();

  static const _host = 'api.themoviedb.org';
  static const _imageBase = 'https://image.tmdb.org/t/p/w185';
  static const _language = 'it-IT';
  static const _timeout = Duration(seconds: 15);

  /// TMDB permette di accodare al massimo 20 "append_to_response".
  static const _maxAppend = 20;

  final String _credential;
  final http.Client _client;

  bool get isConfigured => _credential.isNotEmpty;

  /// La chiave v3 è corta (32 caratteri esadecimali), il token v4 è un JWT.
  bool get _isV3Key => _credential.length <= 40;

  /// GET /3/search/tv — titoli e trame in italiano.
  Future<List<ShowSearchResult>> searchShows(String query) async {
    final q = query.trim();
    if (q.isEmpty || !isConfigured) return const [];

    final json = await _get('/3/search/tv', {'query': q}) as Map<String, dynamic>;
    final results = (json['results'] as List<dynamic>?) ?? const [];
    return results
        .map((r) => parseTmdbSearchResult(r as Map<String, dynamic>))
        .toList();
  }

  /// Serie con episodi. Due passaggi:
  /// 1. dettaglio serie (per sapere quali stagioni esistono);
  /// 2. stagioni richieste a blocchi di 20 con append_to_response.
  ///
  /// Con [onlyRecentSeasons] scarica solo le ultime 2 stagioni: per il
  /// refresh basta, le precedenti non cambiano più.
  Future<ShowWithEpisodes> fetchShowWithEpisodes(
    int tmdbId, {
    bool onlyRecentSeasons = false,
  }) async {
    final details =
        await _get('/3/tv/$tmdbId', const {}) as Map<String, dynamic>;

    var seasons = [
      for (final s in (details['seasons'] as List<dynamic>?) ?? const [])
        // La stagione 0 sono gli speciali: esclusi, come per TVmaze.
        if (((s as Map<String, dynamic>)['season_number'] as int?) case final n?
            when n > 0)
          n,
    ]..sort();
    if (onlyRecentSeasons && seasons.length > 2) {
      seasons = seasons.sublist(seasons.length - 2);
    }

    final showId = tmdbToLocalId(tmdbId);
    final episodes = <EpisodesCompanion>[];
    for (var i = 0; i < seasons.length; i += _maxAppend) {
      final chunk = seasons.sublist(i, math.min(i + _maxAppend, seasons.length));
      final json = await _get('/3/tv/$tmdbId', {
        'append_to_response': chunk.map((n) => 'season/$n').join(','),
      }) as Map<String, dynamic>;
      for (final n in chunk) {
        final season = json['season/$n'] as Map<String, dynamic>?;
        final list = (season?['episodes'] as List<dynamic>?) ?? const [];
        for (final ep in list) {
          episodes.add(parseTmdbEpisode(ep as Map<String, dynamic>, showId));
        }
      }
    }

    return ShowWithEpisodes(
      show: parseTmdbShow(details),
      episodes: episodes,
      fetchedSeasons: onlyRecentSeasons ? seasons.toSet() : null,
    );
  }

  void close() => _client.close();

  Future<dynamic> _get(String path, Map<String, String> params) async {
    final query = {
      'language': _language,
      ...params,
      if (_isV3Key) 'api_key': _credential,
    };
    final headers = {
      'accept': 'application/json',
      if (!_isV3Key) 'Authorization': 'Bearer $_credential',
    };

    final http.Response res;
    try {
      res = await _client
          .get(Uri.https(_host, path, query), headers: headers)
          .timeout(_timeout);
    } on Exception catch (e) {
      throw TmdbException('Errore di rete: $e');
    }

    switch (res.statusCode) {
      case 200:
        return jsonDecode(utf8.decode(res.bodyBytes));
      case 401:
        throw TmdbException('Chiave TMDB non valida', statusCode: 401);
      case 404:
        throw TmdbException('Serie non trovata', statusCode: 404);
      case 429:
        throw TmdbException('Troppe richieste, riprova tra poco',
            statusCode: 429);
      default:
        throw TmdbException('Risposta inattesa', statusCode: res.statusCode);
    }
  }
}

// ---------------------------------------------------------------------------
// Parsing JSON -> modelli. Funzioni pure, testabili senza rete.
// ---------------------------------------------------------------------------

String? _posterUrl(Object? path) =>
    path is String && path.isNotEmpty ? '${TmdbClient._imageBase}$path' : null;

/// "2023-05-09" -> mezzanotte (ora locale) di quel giorno.
/// TMDB non dà l'orario: consideriamo l'episodio uscito a inizio giornata.
DateTime? parseTmdbDate(Object? value) {
  if (value is! String || value.length < 10) return null;
  final d = DateTime.tryParse(value.substring(0, 10));
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

/// Stati TMDB: "Returning Series", "Ended", "Canceled",
/// "In Production", "Planned", "Pilot".
ShowStatus tmdbStatus(String? value) => switch (value) {
      'Returning Series' => ShowStatus.running,
      'Ended' || 'Canceled' => ShowStatus.ended,
      'In Production' || 'Planned' || 'Pilot' => ShowStatus.inDevelopment,
      _ => ShowStatus.unknown,
    };

String _name(Map<String, dynamic> json) {
  final name = json['name'] as String?;
  if (name != null && name.trim().isNotEmpty) return name;
  return (json['original_name'] as String?) ?? 'Senza titolo';
}

ShowSearchResult parseTmdbSearchResult(Map<String, dynamic> json) {
  final countries = (json['origin_country'] as List<dynamic>?) ?? const [];
  return ShowSearchResult(
    id: tmdbToLocalId(json['id'] as int),
    name: _name(json),
    // La ricerca TMDB non indica lo stato: lo sapremo seguendo la serie.
    status: ShowStatus.unknown,
    source: ShowSource.tmdb,
    imageUrl: _posterUrl(json['poster_path']),
    premieredYear: parseTmdbDate(json['first_air_date'])?.year,
    originCountry: countries.isEmpty ? null : countries.first as String,
  );
}

TvShowsCompanion parseTmdbShow(Map<String, dynamic> json) {
  final networks = (json['networks'] as List<dynamic>?) ?? const [];
  final network = networks.isEmpty
      ? null
      : (networks.first as Map<String, dynamic>)['name'] as String?;
  return TvShowsCompanion.insert(
    id: Value(tmdbToLocalId(json['id'] as int)),
    name: _name(json),
    status: tmdbStatus(json['status'] as String?),
    source: const Value(ShowSource.tmdb),
    imageUrl: Value(_posterUrl(json['poster_path'])),
    network: Value(network),
  );
}

EpisodesCompanion parseTmdbEpisode(Map<String, dynamic> ep, int showLocalId) {
  final number = ep['episode_number'] as int?;
  final rawName = (ep['name'] as String?)?.trim();
  return EpisodesCompanion.insert(
    id: Value(tmdbToLocalId(ep['id'] as int)),
    showId: showLocalId,
    season: ep['season_number'] as int,
    number: Value(number),
    name: rawName == null || rawName.isEmpty
        ? (number == null ? 'Episodio senza titolo' : 'Episodio $number')
        : rawName,
    airstamp: Value(parseTmdbDate(ep['air_date'])),
    runtime: Value(ep['runtime'] as int?),
  );
}
