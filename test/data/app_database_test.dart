import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tvmark/data/app_database.dart';
import 'package:tvmark/domain/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> seed() async {
    await db.upsertShow(TvShowsCompanion.insert(
      id: const Value(1),
      name: 'Chicago Fire',
      status: ShowStatus.running,
    ));
    // Stagione 1: ep 1-3, stagione 2: ep 1-2
    final eps = <EpisodesCompanion>[
      for (final (id, s, n) in [
        (11, 1, 1), (12, 1, 2), (13, 1, 3), (21, 2, 1), (22, 2, 2),
      ])
        EpisodesCompanion.insert(
          id: Value(id),
          showId: 1,
          season: s,
          number: Value(n),
          name: 'S${s}E$n',
        ),
    ];
    await db.insertNewEpisodes(eps);
  }

  Future<Map<int, WatchStatus>> statuses() async {
    final list = await db.watchEpisodesOf(1).first;
    return {for (final e in list) e.id: e.watchStatus};
  }

  test('nuovi episodi partono come "da vedere"', () async {
    await seed();
    final s = await statuses();
    expect(s.values, everyElement(WatchStatus.toWatch));
  });

  test('markWatchedUpTo segna i precedenti ma non i successivi né i saltati',
      () async {
    await seed();
    await db.markStatus(12, WatchStatus.skipped);

    final target = (await db.watchEpisodesOf(1).first)
        .firstWhere((e) => e.id == 21); // S2E1
    await db.markWatchedUpTo(target);

    final s = await statuses();
    expect(s[11], WatchStatus.watched);
    expect(s[12], WatchStatus.skipped); // resta saltato
    expect(s[13], WatchStatus.watched);
    expect(s[21], WatchStatus.watched);
    expect(s[22], WatchStatus.toWatch); // successivo, non toccato
  });

  test('markSeasonWatched segna solo la stagione indicata', () async {
    await seed();
    await db.markSeasonWatched(1, 1);
    final s = await statuses();
    expect([s[11], s[12], s[13]], everyElement(WatchStatus.watched));
    expect([s[21], s[22]], everyElement(WatchStatus.toWatch));
  });

  test('reinserire un episodio esistente non ne azzera lo stato', () async {
    await seed();
    await db.markStatus(11, WatchStatus.watched);
    await seed(); // simula un secondo download degli stessi episodi
    final s = await statuses();
    expect(s[11], WatchStatus.watched);
  });

  test('markStatus su "da vedere" azzera la data di visione', () async {
    await seed();
    await db.markStatus(11, WatchStatus.watched);
    await db.markStatus(11, WatchStatus.toWatch);
    final ep = (await db.watchEpisodesOf(1).first).firstWhere((e) => e.id == 11);
    expect(ep.watchedAt, isNull);
  });

  test('cancellare una serie cancella i suoi episodi', () async {
    await seed();
    await db.deleteShow(1);
    expect(await db.watchEpisodesOf(1).first, isEmpty);
  });

  test('meta: lettura e scrittura', () async {
    expect(await db.getMeta('lastRefresh'), isNull);
    await db.setMeta('lastRefresh', '2026-11-16T15:00:00Z');
    await db.setMeta('lastRefresh', '2026-11-16T16:00:00Z');
    expect(await db.getMeta('lastRefresh'), '2026-11-16T16:00:00Z');
  });
}
