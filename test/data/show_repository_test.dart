import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tvmark/data/app_database.dart';
import 'package:tvmark/data/show_repository.dart';
import 'package:tvmark/data/tvmaze_client.dart';
import 'package:tvmark/domain/enums.dart';

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

  setUp(() {
    calls = [];
    updatesBody = '{}';
    showEndpointFails = false;
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
    repo = ShowRepository(db: db, api: api, rateLimitBackoff: Duration.zero);
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
}
