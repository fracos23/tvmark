import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tvmark/data/tvmaze_client.dart';
import 'package:tvmark/domain/enums.dart';

import '../fixtures/tvmaze_fixtures.dart';

TvmazeClient clientReturning(String body, {int status = 200, void Function(http.Request)? onRequest}) {
  return TvmazeClient(
    client: MockClient((request) async {
      onRequest?.call(request);
      return http.Response(body, status,
          headers: {'content-type': 'application/json; charset=utf-8'});
    }),
  );
}

void main() {
  group('searchShows', () {
    test('chiama /search/shows con la query e converte i risultati', () async {
      late Uri calledUri;
      final client = clientReturning(searchChicagoFireJson,
          onRequest: (r) => calledUri = r.url);

      final results = await client.searchShows('  chicago fire ');

      expect(calledUri.host, 'api.tvmaze.com');
      expect(calledUri.path, '/search/shows');
      expect(calledUri.queryParameters['q'], 'chicago fire'); // trim

      expect(results, hasLength(2));
      final cf = results.first;
      expect(cf.id, 1316);
      expect(cf.name, 'Chicago Fire');
      expect(cf.status, ShowStatus.running);
      expect(cf.network, 'NBC');
      expect(cf.premieredYear, 2012);
      expect(cf.imageUrl, 'https://static.tvmaze.com/medium.jpg');
    });

    test('serie streaming: usa webChannel, gestisce immagine e data nulle',
        () async {
      final results =
          await clientReturning(searchChicagoFireJson).searchShows('x');
      final s = results[1];
      expect(s.network, 'Netflix');
      expect(s.imageUrl, isNull);
      expect(s.premieredYear, isNull);
      expect(s.status, ShowStatus.ended);
    });

    test('query vuota: nessuna chiamata di rete', () async {
      var called = false;
      final client =
          clientReturning('[]', onRequest: (_) => called = true);
      expect(await client.searchShows('   '), isEmpty);
      expect(called, isFalse);
    });
  });

  group('fetchShowWithEpisodes', () {
    test('chiama /shows/{id}?embed=episodes', () async {
      late Uri calledUri;
      await clientReturning(showWithEpisodesJson,
              onRequest: (r) => calledUri = r.url)
          .fetchShowWithEpisodes(1316);
      expect(calledUri.path, '/shows/1316');
      expect(calledUri.queryParameters['embed'], 'episodes');
    });

    test('converte serie ed episodi, inclusi i casi limite', () async {
      final result = await clientReturning(showWithEpisodesJson)
          .fetchShowWithEpisodes(1316);

      expect(result.show.id.value, 1316);
      expect(result.show.name.value, 'Chicago Fire');
      expect(result.show.network.value, 'NBC');
      expect(result.show.tvmazeUpdated.value, 1763000000);

      final eps = {for (final e in result.episodes) e.id.value: e};
      expect(eps, hasLength(5));

      // Episodio normale: airstamp convertito in UTC
      expect(eps[100]!.airstamp.value, DateTime.utc(2012, 10, 11, 2));
      expect(eps[100]!.showId.value, 1316);

      // Annunciato senza data
      expect(eps[102]!.airstamp.value, isNull);

      // Speciale senza numero e con airstamp vuoto
      expect(eps[103]!.number.value, isNull);
      expect(eps[103]!.airstamp.value, isNull);

      // Titolo mancante
      expect(eps[104]!.name.value, 'Episodio senza titolo');
    });
  });

  group('errori', () {
    test('429 -> TvmazeException con isRateLimited', () async {
      final client = clientReturning('', status: 429);
      expect(
        () => client.searchShows('x'),
        throwsA(isA<TvmazeException>()
            .having((e) => e.isRateLimited, 'isRateLimited', isTrue)),
      );
    });

    test('404 -> TvmazeException', () async {
      final client = clientReturning('', status: 404);
      expect(
        () => client.fetchShowWithEpisodes(1),
        throwsA(isA<TvmazeException>()
            .having((e) => e.statusCode, 'statusCode', 404)),
      );
    });
  });
}
