import '../domain/enums.dart';
import 'app_database.dart';

/// Errore di una delle API esterne (TVmaze o TMDB).
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// 429: troppe richieste in poco tempo.
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

/// Risultato di ricerca: NON viene salvato nel database finché
/// l'utente non sceglie di seguire la serie.
class ShowSearchResult {
  const ShowSearchResult({
    required this.id,
    required this.name,
    required this.status,
    this.source = ShowSource.tvmaze,
    this.imageUrl,
    this.network,
    this.premieredYear,
    this.originCountry,
  });

  /// Id LOCALE: per TMDB è negativo (vedi ShowSource).
  final int id;
  final String name;
  final ShowStatus status;
  final ShowSource source;
  final String? imageUrl;
  final String? network;
  final int? premieredYear;

  /// Codice paese di origine (es. "IT"), quando la fonte lo fornisce.
  final String? originCountry;
}

/// Serie + episodi pronti per essere scritti nel database.
class ShowWithEpisodes {
  const ShowWithEpisodes({
    required this.show,
    required this.episodes,
    this.fetchedSeasons,
  });

  final TvShowsCompanion show;
  final List<EpisodesCompanion> episodes;

  /// Stagioni effettivamente scaricate. Null = tutte.
  /// Serve a non cancellare le stagioni vecchie quando se ne scaricano
  /// solo le ultime (refresh TMDB).
  final Set<int>? fetchedSeasons;
}
