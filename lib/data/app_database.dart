import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/enums.dart';
import '../domain/home_sections.dart';
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

  Future<List<TvShow>> getShows() => select(tvShows).get();

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

  /// Allinea gli episodi di una serie a quelli appena scaricati da TVmaze:
  /// - nuovi -> inseriti come "da vedere";
  /// - esistenti -> aggiornati SOLO nei campi dell'API (titolo, data...),
  ///   lo stato di visione dell'utente non viene toccato;
  /// - non più presenti su TVmaze -> eliminati.
  /// Tutto in un'unica batch, quindi atomico.
  Future<void> syncEpisodes(int showId, List<EpisodesCompanion> fromApi) {
    // Protezione: se l'API restituisce zero episodi (anomalia), non
    // cancelliamo tutto quello che c'è in locale.
    if (fromApi.isEmpty) return Future.value();

    final ids = fromApi.map((e) => e.id.value).toList();
    return batch((b) {
      for (final ep in fromApi) {
        b.insert(
          episodes,
          ep,
          onConflict: DoUpdate((_) => EpisodesCompanion(
                season: ep.season,
                number: ep.number,
                name: ep.name,
                airstamp: ep.airstamp,
                runtime: ep.runtime,
              )),
        );
      }
      b.deleteWhere(
          episodes, (e) => e.showId.equals(showId) & e.id.isNotIn(ids));
    });
  }

  /// Episodi che servono alla home, con la loro serie:
  /// tutti quelli "da vedere" + tutti quelli futuri.
  /// Esclude il grosso dello storico (episodi passati già visti/saltati).
  Stream<List<ShowEpisode>> watchRelevantEpisodes() {
    final query = select(episodes).join([
      innerJoin(tvShows, tvShows.id.equalsExp(episodes.showId)),
    ])
      ..where(episodes.watchStatus.equalsValue(WatchStatus.toWatch) |
          episodes.airstamp.isBiggerThan(currentDateAndTime));
    return query.watch().map((rows) => [
          for (final r in rows)
            ShowEpisode(r.readTable(tvShows), r.readTable(episodes)),
        ]);
  }

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

  /// Per ogni serie: quanti episodi già usciti sono ancora "da vedere".
  /// Il confronto con l'ora attuale è fatto in SQL (currentDateAndTime).
  /// Gli episodi senza data non contano (NULL non supera il confronto).
  Stream<Map<int, int>> watchAiredToWatchCounts() {
    final count = episodes.id.count();
    final query = selectOnly(episodes)
      ..addColumns([episodes.showId, count])
      ..where(episodes.watchStatus.equalsValue(WatchStatus.toWatch) &
          episodes.airstamp.isSmallerOrEqual(currentDateAndTime))
      ..groupBy([episodes.showId]);
    return query.watch().map((rows) => {
          for (final r in rows) r.read(episodes.showId)!: r.read(count) ?? 0,
        });
  }

  // ---------------- Meta ----------------

  Future<String?> getMeta(String key) async {
    final row = await (select(appMeta)..where((m) => m.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) => into(appMeta)
      .insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));
}
