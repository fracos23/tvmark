import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TvShows, Episodes, AppMeta])
class AppDatabase extends _$AppDatabase {
  /// [executor] serve solo ai test (database in memoria).
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'tvmark'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // SQLite non applica le foreign key (e quindi il cascade) se non
          // le si attiva esplicitamente a ogni apertura.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ---------------- Serie ----------------

  Stream<List<TvShow>> watchShows() => (select(tvShows)
        ..orderBy([(s) => OrderingTerm.asc(s.name)]))
      .watch();

  Future<void> upsertShow(TvShowsCompanion show) =>
      into(tvShows).insertOnConflictUpdate(show);

  /// Cancella la serie; i suoi episodi spariscono in cascata.
  Future<int> deleteShow(int showId) =>
      (delete(tvShows)..where((s) => s.id.equals(showId))).go();

  // ---------------- Episodi ----------------

  Stream<List<Episode>> watchEpisodesOf(int showId) => (select(episodes)
        ..where((e) => e.showId.equals(showId))
        ..orderBy([
          (e) => OrderingTerm.asc(e.season),
          (e) => OrderingTerm.asc(e.number),
        ]))
      .watch();

  /// Inserisce solo gli episodi che non esistono ancora (insertOrIgnore):
  /// quelli già presenti mantengono il loro stato di visione.
  /// L'aggiornamento delle date sugli esistenti arriva con lo sprint del refresh.
  Future<void> insertNewEpisodes(List<EpisodesCompanion> list) =>
      batch((b) => b.insertAll(episodes, list, mode: InsertMode.insertOrIgnore));

  Future<int> markStatus(int episodeId, WatchStatus status) =>
      (update(episodes)..where((e) => e.id.equals(episodeId))).write(
        EpisodesCompanion(
          watchStatus: Value(status),
          watchedAt: Value(status == WatchStatus.watched ? DateTime.now() : null),
        ),
      );

  /// "Segna visti fino a qui": marca come visti tutti gli episodi
  /// ancora "da vedere" della stessa serie fino a [ep] incluso.
  /// Gli episodi "saltati" restano saltati.
  Future<int> markWatchedUpTo(Episode ep) {
    final n = ep.number;
    return (update(episodes)
          ..where((e) {
            final sameSeasonUpTo = n == null
                ? e.id.equals(ep.id)
                : e.number.isSmallerOrEqualValue(n);
            final upTo = e.season.isSmallerThanValue(ep.season) |
                (e.season.equals(ep.season) & sameSeasonUpTo);
            return e.showId.equals(ep.showId) &
                e.watchStatus.equalsValue(WatchStatus.toWatch) &
                upTo;
          }))
        .write(EpisodesCompanion(
      watchStatus: const Value(WatchStatus.watched),
      watchedAt: Value(DateTime.now()),
    ));
  }

  /// Segna come vista un'intera stagione (solo gli episodi "da vedere").
  Future<int> markSeasonWatched(int showId, int season) => (update(episodes)
        ..where((e) =>
            e.showId.equals(showId) &
            e.season.equals(season) &
            e.watchStatus.equalsValue(WatchStatus.toWatch)))
      .write(EpisodesCompanion(
        watchStatus: const Value(WatchStatus.watched),
        watchedAt: Value(DateTime.now()),
      ));

  // ---------------- Meta ----------------

  Future<String?> getMeta(String key) async {
    final row = await (select(appMeta)..where((m) => m.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) => into(appMeta)
      .insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));
}
