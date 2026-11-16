import 'package:drift/drift.dart';

import '../domain/enums.dart';
import '../domain/home_sections.dart';
import 'app_database.dart';
import 'tmdb_client.dart';
import 'tvmaze_client.dart';

/// Esito di un refresh.
class RefreshResult {
  const RefreshResult({
    this.skipped = false,
    this.updatedShows = 0,
    this.failedShows = 0,
  });

  /// True se il refresh non è partito perché quello precedente è troppo recente.
  final bool skipped;
  final int updatedShows;
  final int failedShows;
}

/// Risultati di una ricerca su entrambe le fonti.
class SearchResults {
  const SearchResults({
    required this.primary,
    this.secondary = const [],
    this.secondaryFailed = false,
  });

  /// Da TVmaze, la fonte principale.
  final List<ShowSearchResult> primary;

  /// Da TMDB, solo le serie che TVmaze non ha già restituito.
  final List<ShowSearchResult> secondary;

  /// True se la ricerca su TMDB è fallita (TVmaze invece è andata).
  final bool secondaryFailed;
}

/// Unico punto di accesso ai dati per la UI: mette insieme
/// database locale (Drift) e API (TVmaze principale, TMDB secondaria).
class ShowRepository {
  ShowRepository({
    required this._db,
    required this._api,
    this._tmdb,
    this.minRefreshInterval = const Duration(hours: 1),
    this.rateLimitBackoff = const Duration(seconds: 5),
  });

  final AppDatabase _db;
  final TvmazeClient _api;

  /// Opzionale: senza chiave TMDB l'app funziona solo con TVmaze.
  final TmdbClient? _tmdb;

  /// Sotto questo intervallo il refresh automatico non riparte.
  final Duration minRefreshInterval;

  /// Attesa prima di riprovare dopo un 429 (troppe richieste).
  final Duration rateLimitBackoff;

  static const _lastRefreshKey = 'lastRefresh';

  /// Se un refresh è già in corso, chi lo richiede riceve lo stesso Future
  /// invece di farne partire un secondo in parallelo.
  Future<RefreshResult>? _inFlight;

  bool get tmdbEnabled => _tmdb?.isConfigured ?? false;

  // ---- Ricerca / follow ----

  /// Solo TVmaze.
  Future<List<ShowSearchResult>> search(String query) =>
      _api.searchShows(query);

  /// TVmaze + TMDB in parallelo. I risultati TMDB che corrispondono a
  /// uno di TVmaze (stesso titolo, stesso anno) vengono scartati: per
  /// quelle serie TVmaze resta la prima scelta.
  ///
  /// Un errore di TVmaze viene propagato; un errore di TMDB no
  /// (si mostrano comunque i risultati di TVmaze).
  Future<SearchResults> searchAll(String query) async {
    // Parte subito, in parallelo alla ricerca TVmaze.
    final tmdbFuture = _safeTmdbSearch(query);
    final primary = await _api.searchShows(query);
    final tmdb = await tmdbFuture;

    if (tmdb == null) {
      return SearchResults(primary: primary, secondaryFailed: true);
    }
    return SearchResults(
      primary: primary,
      secondary: [
        for (final r in tmdb)
          if (!primary.any((p) => _sameShow(p, r))) r,
      ],
    );
  }

  Future<List<ShowSearchResult>?> _safeTmdbSearch(String query) async {
    final tmdb = _tmdb;
    if (tmdb == null || !tmdb.isConfigured) return const [];
    try {
      return await tmdb.searchShows(query);
    } on ApiException {
      return null;
    }
  }

  /// Titolo "normalizzato" (minuscolo, solo lettere e cifre).
  static String _normalize(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9à-ÿ]'), '');

  static bool _sameShow(ShowSearchResult a, ShowSearchResult b) {
    if (_normalize(a.name) != _normalize(b.name)) return false;
    final ya = a.premieredYear;
    final yb = b.premieredYear;
    return ya == null || yb == null || ya == yb;
  }

  /// Seguire una serie = sincronizzarla la prima volta.
  /// La fonte si deduce dall'id locale (negativo = TMDB).
  Future<void> followShow(int localId) => _syncShow(localId);

  Future<int> unfollowShow(int showId) => _db.deleteShow(showId);

  // ---- Refresh ----

  /// Aggiorna le serie seguite.
  ///
  /// - Senza [force], se l'ultimo refresh riuscito è più recente di
  ///   [minRefreshInterval] non fa nulla.
  /// - Serie TVmaze: se l'ultimo refresh è entro 30 giorni, chiede a TVmaze
  ///   (una sola chiamata) quali sono cambiate e riscarica solo quelle;
  ///   altrimenti le riscarica tutte.
  /// - Serie TMDB non concluse: TMDB non ha un equivalente comodo di
  ///   /updates, quindi vengono ricontrollate tutte, scaricando solo le
  ///   ultime 2 stagioni.
  ///
  /// Se una serie fallisce, la data dell'ultimo refresh NON viene salvata,
  /// così al giro successivo viene ricontrollata.
  Future<RefreshResult> refresh({bool force = false, DateTime? now}) {
    return _inFlight ??= _doRefresh(force: force, now: now ?? DateTime.now())
        .whenComplete(() => _inFlight = null);
  }

  Future<RefreshResult> _doRefresh({
    required bool force,
    required DateTime now,
  }) async {
    final lastValue = await _db.getMeta(_lastRefreshKey);
    final last = lastValue == null ? null : DateTime.tryParse(lastValue);

    if (!force && last != null && now.difference(last) < minRefreshInterval) {
      return const RefreshResult(skipped: true);
    }

    final shows = await _db.getShows();
    final tvmazeShows =
        shows.where((s) => s.source == ShowSource.tvmaze).toList();
    final tmdbShows = tmdbEnabled
        ? shows
            .where((s) =>
                s.source == ShowSource.tmdb && s.status != ShowStatus.ended)
            .toList()
        : const <TvShow>[];

    final List<int> tvmazeToFetch;
    final since = _sinceParam(last, now);
    if (since == null) {
      tvmazeToFetch = tvmazeShows.map((s) => s.id).toList();
    } else if (tvmazeShows.isEmpty) {
      tvmazeToFetch = const [];
    } else {
      final updates = await _api.fetchShowUpdates(since: since);
      tvmazeToFetch = [
        for (final s in tvmazeShows)
          if (updates[s.id] case final remote?
              when s.tvmazeUpdated == null || remote > s.tvmazeUpdated!)
            s.id,
      ];
    }

    var updated = 0;
    var failed = 0;
    Future<void> sync(int id, {bool recentOnly = false}) async {
      if (await _syncShowWithRetry(id, recentOnly: recentOnly)) {
        updated++;
      } else {
        failed++;
      }
    }

    for (final id in tvmazeToFetch) {
      await sync(id);
    }
    for (final s in tmdbShows) {
      await sync(s.id, recentOnly: true);
    }

    if (failed == 0) {
      await _db.setMeta(_lastRefreshKey, now.toUtc().toIso8601String());
    }
    return RefreshResult(updatedShows: updated, failedShows: failed);
  }

  /// Finestra per /updates/shows, con un po' di margine rispetto
  /// a giorno/settimana/mese. Null = riscarica tutto.
  static String? _sinceParam(DateTime? last, DateTime now) {
    if (last == null) return null;
    final elapsed = now.difference(last);
    if (elapsed < const Duration(hours: 20)) return 'day';
    if (elapsed < const Duration(days: 6)) return 'week';
    if (elapsed < const Duration(days: 28)) return 'month';
    return null;
  }

  Future<bool> _syncShowWithRetry(int showId, {bool recentOnly = false}) async {
    try {
      await _syncShow(showId, recentOnly: recentOnly);
      return true;
    } on ApiException catch (e) {
      if (!e.isRateLimited) return false;
      await Future<void>.delayed(rateLimitBackoff);
      try {
        await _syncShow(showId, recentOnly: recentOnly);
        return true;
      } on ApiException {
        return false;
      }
    }
  }

  /// Scarica e salva una serie dalla sua fonte.
  /// [recentOnly] vale solo per TMDB (ultime 2 stagioni).
  Future<void> _syncShow(int localId, {bool recentOnly = false}) async {
    final ShowWithEpisodes data;
    if (ShowSource.ofLocalId(localId) == ShowSource.tmdb) {
      final tmdb = _tmdb;
      if (tmdb == null || !tmdb.isConfigured) {
        throw TmdbException('TMDB non configurato');
      }
      data = await tmdb.fetchShowWithEpisodes(
        localToTmdbId(localId),
        onlyRecentSeasons: recentOnly,
      );
    } else {
      data = await _api.fetchShowWithEpisodes(localId);
    }

    await _db.transaction(() async {
      await _db.upsertShow(
          data.show.copyWith(lastSyncedAt: Value(DateTime.now())));
      await _db.syncEpisodes(
        localId,
        data.episodes,
        onlySeasons: data.fetchedSeasons,
      );
    });
  }

  // ---- Letture ----

  Stream<List<TvShow>> watchShows() => _db.watchShows();

  Stream<Map<int, int>> watchAiredToWatchCounts() =>
      _db.watchAiredToWatchCounts();

  Stream<List<ShowEpisode>> watchRelevantEpisodes() =>
      _db.watchRelevantEpisodes();

  Stream<List<Episode>> watchEpisodesOf(int showId) =>
      _db.watchEpisodesOf(showId);

  // ---- Stati di visione ----

  Future<int> markStatus(int episodeId, WatchStatus status) =>
      _db.markStatus(episodeId, status);

  Future<int> markWatchedUpTo(Episode episode) =>
      _db.markWatchedUpTo(episode);

  Future<int> markSeasonWatched(int showId, int season) =>
      _db.markSeasonWatched(showId, season);
}
