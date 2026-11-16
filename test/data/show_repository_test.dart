import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tvmark/data/app_database.dart';
import 'package:tvmark/data/show_repository.dart';
import 'package:tvmark/data/tmdb_client.dart';
import 'package:tvmark/data/tvmaze_client.dart';
import 'package:tvmark/domain/enums.dart';

import '../fixtures/tmdb_fixtures.dart';
import '../fixtures/tvmaze_fixtures.dart';

http.Response _json(String body, [int status = 200]) => http.Response(
      body,
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  late AppDatabase db;
  late ShowRepository repo;

  /// Percorsi chiamati, per verificare quante e quali richieste partono.
  late List<String> calls;

  /// Risposta di /updates/shows, modificabile nei singoli test.
  late String updatesBody;

  /// Se true, /shows/{id} risponde 500.
  late bool showEndpointFails;

  /// Chiamate a TMDB (path + append_to_response) e risposta della ricerca.
  late List<String> tmdbCalls;
  late String tmdbSearchBody;

  setUp(() {
    calls = [];
    updatesBody = '{}';
    showEndpointFails = false;
    tmdbCalls = [];
    tmdbSearchBody = tmdbSearchJson;
    db = AppDatabase(NativeDatabase.memory());
    final api = TvmazeClient(
      client: MockClient((req) async {
        calls.add(req.url.path);
        if (req.url.path == '/updates/shows') return _json(updatesBody);
        if (req.url.path == '/shows/1316') {
          return showEndpointFails
              ? _json('', 500)
              : _json(showWithEpisodesJson);
        }
        return _json('', 404);
      }),
    );
    final tmdb = TmdbClient(
      credential: 'token-finto-di-test-abbastanza-lungo-per-essere-v4-jwt',
      client: MockClient((req) async {
        final append = req.url.queryParameters['append_to_response'];
        tmdbCalls.add(append == null ? req.url.path : '${req.url.path}?$append');
        if (req.url.path == '/3/search/tv') return _json(tmdbSearchBody);
        if (req.url.path == '/3/tv/226680') return _json(tmdbShowJson);
        return _json('', 404);
      }),
    );
    repo = ShowRepository(
      db: db,
      api: api,
      tmdb: tmdb,
      rateLimitBackoff: Duration.zero,
    );
  });

  tearDown(() => db.close());

  final t0 = DateTime.utc(2026, 11, 16, 12);

  group('follow', () {
    test('followShow salva serie ed episodi', () async {
      await repo.followShow(1316);

      final shows = await repo.watchShows().first;
      expect(shows, hasLength(1));
      expect(shows.single.name, 'Chicago Fire');
      expect(shows.single.status, ShowStatus.running);
      expect(shows.single.lastSyncedAt, isNotNull);
      expect(await repo.watchEpisodesOf(1316).first, hasLength(5));
    });

    test('seguire di nuovo la stessa serie non azzera gli stati', () async {
      await repo.followShow(1316);
      await repo.markStatus(100, WatchStatus.watched);
      await repo.followShow(1316);

      final ep = (await repo.watchEpisodesOf(1316).first)
          .firstWhere((e) => e.id == 100);
      expect(ep.watchStatus, WatchStatus.watched);
      expect(await repo.watchShows().first, hasLength(1));
    });

    test('unfollowShow elimina serie ed episodi', () async {
      await repo.followShow(1316);
      await repo.unfollowShow(1316);
      expect(await repo.watchShows().first, isEmpty);
      expect(await repo.watchEpisodesOf(1316).first, isEmpty);
    });
  });

  group('refresh', () {
    setUp(() async {
      await repo.followShow(1316); // tvmazeUpdated = 1763000000
      calls.clear();
    });

    test('primo refresh: riscarica tutte le serie, senza /updates', () async {
      final r = await repo.refresh(now: t0);
      expect(calls, ['/shows/1316']);
      expect(r.updatedShows, 1);
    });

    test('entro un\'ora: refresh automatico saltato', () async {
      await repo.refresh(now: t0);
      calls.clear();

      final r = await repo.refresh(now: t0.add(const Duration(minutes: 10)));
      expect(r.skipped, isTrue);
      expect(calls, isEmpty);
    });

    test('refresh forzato, serie non cambiata: solo /updates', () async {
      await repo.refresh(now: t0);
      calls.clear();
      updatesBody = '{"1316": 1763000000}';

      final r = await repo.refresh(
          force: true, now: t0.add(const Duration(minutes: 10)));
      expect(calls, ['/updates/shows']);
      expect(r.updatedShows, 0);
    });

    test('serie cambiata su TVmaze: viene riscaricata', () async {
      await repo.refresh(now: t0);
      calls.clear();
      updatesBody = '{"1316": 1763000999, "42": 1}';

      final r = await repo.refresh(now: t0.add(const Duration(hours: 2)));
      expect(calls, ['/updates/shows', '/shows/1316']);
      expect(r.updatedShows, 1);
    });

    test('se una serie fallisce, il refresh successivo non viene saltato',
        () async {
      showEndpointFails = true;
      final r = await repo.refresh(now: t0);
      expect(r.failedShows, 1);

      showEndpointFails = false;
    tmdbCalls = [];
    tmdbSearchBody = tmdbSearchJson;
      calls.clear();
      final r2 = await repo.refresh(now: t0.add(const Duration(minutes: 10)));
      expect(r2.skipped, isFalse);
      expect(calls, ['/shows/1316']); // ancora "primo" refresh completo
    });

    test('due refresh contemporanei: una sola esecuzione', () async {
      final results =
          await Future.wait([repo.refresh(now: t0), repo.refresh(now: t0)]);
      expect(calls, ['/shows/1316']);
      expect(identical(results[0], results[1]), isTrue);
    });
  });

  group('TMDB', () {
    test('followShow con id negativo usa TMDB e salva la fonte', () async {
      await repo.followShow(-226680);

      final show = (await repo.watchShows().first).single;
      expect(show.id, -226680);
      expect(show.source, ShowSource.tmdb);
      expect(show.network, 'TV8');
      expect(await repo.watchEpisodesOf(-226680).first, hasLength(4));
      expect(calls, isEmpty); // TVmaze non toccato
    });

    test('refresh: serie TMDB riscaricate solo nelle ultime stagioni, '
        'le vecchie restano', () async {
      await repo.followShow(-226680);
      await repo.markStatus(-1001, WatchStatus.watched); // stagione 1
      tmdbCalls.clear();

      final r = await repo.refresh(now: t0);

      expect(r.updatedShows, 1);
      expect(tmdbCalls, ['/3/tv/226680', '/3/tv/226680?season/2,season/3']);
      final eps = {
        for (final e in await repo.watchEpisodesOf(-226680).first) e.id: e,
      };
      expect(eps.keys, containsAll([-1001, -2001, -2002, -3001]));
      expect(eps[-1001]!.watchStatus, WatchStatus.watched);
    });

    test('refresh: serie TMDB concluse non vengono ricontrollate', () async {
      await repo.followShow(-226680);
      // Simula una serie conclusa (update parziale: tocca solo lo stato).
      await (db.update(db.tvShows)..where((s) => s.id.equals(-226680)))
          .write(const TvShowsCompanion(status: Value(ShowStatus.ended)));
      tmdbCalls.clear();

      await repo.refresh(now: t0);
      expect(tmdbCalls, isEmpty);
    });
  });

  group('searchAll', () {
    test('TMDB aggiunge solo le serie che TVmaze non ha', () async {
      // TVmaze restituisce Chicago Fire (2012) e una serie streaming;
      // TMDB restituisce Chicago Fire (2012, duplicato) e GialappaShow.
      tmdbSearchBody = '''
      {"results": [
        {"id": 44006, "name": "Chicago Fire", "first_air_date": "2012-10-10",
         "poster_path": null, "origin_country": ["US"]},
        {"id": 226680, "name": "GialappaShow", "first_air_date": "2023-05-09",
         "poster_path": null, "origin_country": ["IT"]}
      ]}
      ''';
      final api = TvmazeClient(
        client: MockClient((_) async => _json(searchChicagoFireJson)),
      );
      final tmdb = TmdbClient(
        credential: 'token-finto-di-test-abbastanza-lungo-per-essere-v4-jwt',
        client: MockClient((_) async => _json(tmdbSearchBody)),
      );
      final r = await ShowRepository(db: db, api: api, tmdb: tmdb)
          .searchAll('chicago');

      expect(r.primary.map((s) => s.name),
          ['Chicago Fire', 'Serie streaming senza immagine']);
      expect(r.secondary.map((s) => s.name), ['GialappaShow']);
      expect(r.secondary.single.id, -226680);
      expect(r.secondaryFailed, isFalse);
    });

    test('se TMDB fallisce, restano i risultati TVmaze', () async {
      final api = TvmazeClient(
        client: MockClient((_) async => _json(searchChicagoFireJson)),
      );
      final tmdb = TmdbClient(
        credential: 'token-finto-di-test-abbastanza-lungo-per-essere-v4-jwt',
        client: MockClient((_) async => _json('', 500)),
      );
      final r = await ShowRepository(db: db, api: api, tmdb: tmdb)
          .searchAll('chicago');
      expect(r.primary, hasLength(2));
      expect(r.secondary, isEmpty);
      expect(r.secondaryFailed, isTrue);
    });

    test('senza chiave TMDB: nessuna ricerca TMDB', () async {
      final api = TvmazeClient(
        client: MockClient((_) async => _json(searchChicagoFireJson)),
      );
      final r = await ShowRepository(
        db: db,
        api: api,
        tmdb: TmdbClient(credential: ''),
      ).searchAll('chicago');
      expect(r.secondary, isEmpty);
      expect(r.secondaryFailed, isFalse);
    });
  });
}

