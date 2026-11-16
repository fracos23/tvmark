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

  test('conteggio episodi usciti da vedere, per serie', () async {
    await db.upsertShow(TvShowsCompanion.insert(
      id: const Value(1),
      name: 'Serie',
      status: ShowStatus.running,
    ));
    final now = DateTime.now();
    EpisodesCompanion ep(int id, DateTime? air) => EpisodesCompanion.insert(
          id: Value(id),
          showId: 1,
          season: 1,
          number: Value(id),
          name: 'E$id',
          airstamp: Value(air),
        );
    await db.insertNewEpisodes([
      ep(1, now.subtract(const Duration(days: 2))), // uscito, da vedere
      ep(2, now.subtract(const Duration(days: 1))), // uscito, poi visto
      ep(3, now.add(const Duration(days: 7))), // futuro
      ep(4, null), // senza data
    ]);
    await db.markStatus(2, WatchStatus.watched);

    final counts = await db.watchAiredToWatchCounts().first;
    expect(counts, {1: 1});
  });

  group('syncEpisodes', () {
    EpisodesCompanion apiEp(int id, int number, DateTime? air,
            {String? name}) =>
        EpisodesCompanion.insert(
          id: Value(id),
          showId: 1,
          season: 1,
          number: Value(number),
          name: name ?? 'E$number',
          airstamp: Value(air),
        );

    setUp(() => db.upsertShow(TvShowsCompanion.insert(
          id: const Value(1),
          name: 'Serie',
          status: ShowStatus.running,
        )));

    test('aggiorna date e titoli, mantiene lo stato, aggiunge e rimuove',
        () async {
      await db.syncEpisodes(1, [
        apiEp(1, 1, DateTime.utc(2026, 11, 1)),
        apiEp(2, 2, DateTime.utc(2026, 11, 8)),
        apiEp(3, 3, null),
      ]);
      await db.markStatus(1, WatchStatus.watched);

      // Secondo download: ep1 rinominato, ep2 spostato, ep3 ora ha data,
      // ep4 nuovo... ep2 resta, ep3 resta. Poi verifichiamo la rimozione.
      await db.syncEpisodes(1, [
        apiEp(1, 1, DateTime.utc(2026, 11, 1), name: 'Pilot'),
        apiEp(2, 2, DateTime.utc(2026, 11, 15)),
        apiEp(3, 3, DateTime.utc(2026, 12, 1)),
        apiEp(4, 4, null),
      ]);

      var eps = {for (final e in await db.watchEpisodesOf(1).first) e.id: e};
      expect(eps.keys, [1, 2, 3, 4]);
      expect(eps[1]!.name, 'Pilot');
      expect(eps[1]!.watchStatus, WatchStatus.watched); // stato intatto
      expect(eps[2]!.airstamp!.toUtc(), DateTime.utc(2026, 11, 15));
      expect(eps[3]!.airstamp!.toUtc(), DateTime.utc(2026, 12, 1));
      expect(eps[4]!.watchStatus, WatchStatus.toWatch);

      // Terzo download: ep4 sparito da TVmaze.
      await db.syncEpisodes(1, [
        apiEp(1, 1, DateTime.utc(2026, 11, 1), name: 'Pilot'),
        apiEp(2, 2, DateTime.utc(2026, 11, 15)),
        apiEp(3, 3, DateTime.utc(2026, 12, 1)),
      ]);
      eps = {for (final e in await db.watchEpisodesOf(1).first) e.id: e};
      expect(eps.keys, [1, 2, 3]);
    });

    test('onlySeasons: cancella solo nelle stagioni riscaricate', () async {
      EpisodesCompanion inSeason(int id, int season) => EpisodesCompanion.insert(
            id: Value(id),
            showId: 1,
            season: season,
            number: Value(id),
            name: 'E$id',
          );
      await db.syncEpisodes(1, [inSeason(1, 1), inSeason(2, 2), inSeason(3, 2)]);

      // Riscarico solo la stagione 2, dove l'episodio 3 è sparito.
      await db.syncEpisodes(1, [inSeason(2, 2)], onlySeasons: {2});

      final ids = (await db.watchEpisodesOf(1).first).map((e) => e.id);
      expect(ids, [1, 2]); // stagione 1 intatta, 3 rimosso
    });

    test('lista vuota dall\'API: non cancella nulla', () async {
      await db.syncEpisodes(1, [apiEp(1, 1, null)]);
      await db.syncEpisodes(1, const []);
      expect(await db.watchEpisodesOf(1).first, hasLength(1));
    });
  });
}
