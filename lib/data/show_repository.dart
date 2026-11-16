import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'app_database.dart';
import 'tvmaze_client.dart';

/// Unico punto di accesso ai dati per la UI: mette insieme
/// database locale (Drift) e API (TVmaze).
class ShowRepository {
  ShowRepository({required AppDatabase db, required TvmazeClient api})
      : _db = db,
        _api = api;

  final AppDatabase _db;
  final TvmazeClient _api;

  // ---- Ricerca / follow ----

  Future<List<ShowSearchResult>> search(String query) =>
      _api.searchShows(query);

  /// Scarica serie + episodi e li salva. In transazione: o tutto o niente.
  /// Se la serie era già seguita, gli stati di visione restano intatti.
  Future<void> followShow(int showId) async {
    final data = await _api.fetchShowWithEpisodes(showId);
    await _db.transaction(() async {
      await _db.upsertShow(
          data.show.copyWith(lastSyncedAt: Value(DateTime.now())));
      await _db.insertNewEpisodes(data.episodes);
    });
  }

  Future<int> unfollowShow(int showId) => _db.deleteShow(showId);

  // ---- Letture ----

  Stream<List<TvShow>> watchShows() => _db.watchShows();

  Stream<Map<int, int>> watchAiredToWatchCounts() =>
      _db.watchAiredToWatchCounts();

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
