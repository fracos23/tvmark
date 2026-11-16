import 'package:drift/drift.dart';

import '../domain/enums.dart';
import '../domain/home_sections.dart';
import 'app_database.dart';
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

/// Unico punto di accesso ai dati per la UI: mette insieme
/// database locale (Drift) e API (TVmaze).
class ShowRepository {
  ShowRepository({
    required this._db,
    required this._api,
    this.minRefreshInterval = const Duration(hours: 1),
    this.rateLimitBackoff = const Duration(seconds: 5),
  });

  final AppDatabase _db;
  final TvmazeClient _api;

  /// Sotto questo intervallo il refresh automatico non riparte.
  final Duration minRefreshInterval;

  /// Attesa prima di riprovare dopo un 429 (troppe richieste).
  final Duration rateLimitBackoff;

  static const _lastRefreshKey = 'lastRefresh';

  /// Se un refresh è già in corso, chi lo richiede riceve lo stesso Future
  /// invece di farne partire un secondo in parallelo.
  Future<RefreshResult>? _inFlight;

  // ---- Ricerca / follow ----

  Future<List<ShowSearchResult>> search(String query) =>
      _api.searchShows(query);

  /// Seguire una serie = sincronizzarla la prima volta.
  Future<void> followShow(int showId) => _syncShow(showId);

  Future<int> unfollowShow(int showId) => _db.deleteShow(showId);

  // ---- Refresh ----

  /// Aggiorna le serie seguite.
  ///
  /// - Senza [force], se l'ultimo refresh riuscito è più recente di
  ///   [minRefreshInterval] non fa nulla.
  /// - Se l'ultimo refresh è entro 30 giorni, chiede a TVmaze (una sola
  ///   chiamata) quali serie sono cambiate e riscarica solo quelle.
  /// - Altrimenti (primo refresh o pausa lunga) riscarica tutte le serie.
  ///
  /// Se una serie fallisce, la data dell'ultimo refresh NON viene salvata,
  /// così al giro successivo viene ricontrollata.
  /// Gli errori di rete sulla chiamata /updates vengono propagati.
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
    final Iterable<int> toFetch;

    final since = _sinceParam(last, now);
    if (since == null) {
      toFetch = shows.map((s) => s.id);
    } else {
      final updates = await _api.fetchShowUpdates(since: since);
      toFetch = shows
          .where((s) {
            final remote = updates[s.id];
            final local = s.tvmazeUpdated;
            return remote != null && (local == null || remote > local);
          })
          .map((s) => s.id);
    }

    var updated = 0;
    var failed = 0;
    for (final id in toFetch.toList()) {
      if (await _syncShowWithRetry(id)) {
        updated++;
      } else {
        failed++;
      }
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

  Future<bool> _syncShowWithRetry(int showId) async {
    try {
      await _syncShow(showId);
      return true;
    } on TvmazeException catch (e) {
      if (!e.isRateLimited) return false;
      await Future<void>.delayed(rateLimitBackoff);
      try {
        await _syncShow(showId);
        return true;
      } on TvmazeException {
        return false;
      }
    }
  }

  Future<void> _syncShow(int showId) async {
    final data = await _api.fetchShowWithEpisodes(showId);
    await _db.transaction(() async {
      await _db.upsertShow(
          data.show.copyWith(lastSyncedAt: Value(DateTime.now())));
      await _db.syncEpisodes(showId, data.episodes);
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
