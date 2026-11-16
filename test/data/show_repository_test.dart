import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tvmark/data/app_database.dart';
import 'package:tvmark/data/show_repository.dart';
import 'package:tvmark/data/tvmaze_client.dart';
import 'package:tvmark/domain/enums.dart';

import '../fixtures/tvmaze_fixtures.dart';

void main() {
  late AppDatabase db;
  late ShowRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final api = TvmazeClient(
      client: MockClient((_) async => http.Response(showWithEpisodesJson, 200,
          headers: {'content-type': 'application/json; charset=utf-8'})),
    );
    repo = ShowRepository(db: db, api: api);
  });

  tearDown(() => db.close());

  test('followShow salva serie ed episodi', () async {
    await repo.followShow(1316);

    final shows = await repo.watchShows().first;
    expect(shows, hasLength(1));
    expect(shows.single.name, 'Chicago Fire');
    expect(shows.single.status, ShowStatus.running);
    expect(shows.single.lastSyncedAt, isNotNull);

    final eps = await repo.watchEpisodesOf(1316).first;
    expect(eps, hasLength(5));
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
}
