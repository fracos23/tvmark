import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tvmark/data/tmdb_client.dart';
import 'package:tvmark/domain/enums.dart';

import '../fixtures/tmdb_fixtures.dart';

const v4Token = 'eyJhbGciOiJIUzI1NiJ9.questo-e-un-token-finto-abbastanza-lungo';
const v3Key = '0123456789abcdef0123456789abcdef';

TmdbClient clientWith(
  String body, {
  String credential = v4Token,
  int status = 200,
  List<http.Request>? requests,
}) =>
    TmdbClient(
      credential: credential,
      client: MockClient((req) async {
        requests?.add(req);
        return http.Response(body, status,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }),
    );

void main() {
  group('autenticazione', () {
    test('token v4: header Bearer, niente api_key', () async {
      final requests = <http.Request>[];
      await clientWith(tmdbSearchJson, requests: requests).searchShows('x');
      final r = requests.single;
      expect(r.headers['Authorization'], 'Bearer $v4Token');
      expect(r.url.queryParameters.containsKey('api_key'), isFalse);
      expect(r.url.queryParameters['language'], 'it-IT');
    });

    test('chiave v3: parametro api_key, niente header', () async {
      final requests = <http.Request>[];
      await clientWith(tmdbSearchJson, credential: v3Key, requests: requests)
          .searchShows('x');
      final r = requests.single;
      expect(r.url.queryParameters['api_key'], v3Key);
      expect(r.headers.containsKey('Authorization'), isFalse);
    });

    test('senza chiave: disattivato, nessuna chiamata', () async {
      final requests = <http.Request>[];
      final client = clientWith('{}', credential: '  ', requests: requests);
      expect(client.isConfigured, isFalse);
      expect(await client.searchShows('gialappa'), isEmpty);
      expect(requests, isEmpty);
    });
  });

  group('searchShows', () {
    test('converte i risultati con id negativi e fonte TMDB', () async {
      final results = await clientWith(tmdbSearchJson).searchShows('gialappa');
      expect(results, hasLength(2));

      final g = results.first;
      expect(g.id, -226680);
      expect(g.source, ShowSource.tmdb);
      expect(g.name, 'GialappaShow');
      expect(g.premieredYear, 2023);
      expect(g.originCountry, 'IT');
      expect(g.imageUrl, 'https://image.tmdb.org/t/p/w185/gialappa.jpg');
    });

    test('nome vuoto -> nome originale; campi mancanti -> null', () async {
      final r = (await clientWith(tmdbSearchJson).searchShows('x'))[1];
      expect(r.name, 'Titolo originale');
      expect(r.imageUrl, isNull);
      expect(r.premieredYear, isNull);
      expect(r.originCountry, isNull);
    });
  });

  group('fetchShowWithEpisodes', () {
    test('scarica tutte le stagioni tranne la 0, in una sola chiamata extra',
        () async {
      final requests = <http.Request>[];
      final result = await clientWith(tmdbShowJson, requests: requests)
          .fetchShowWithEpisodes(226680);

      expect(requests, hasLength(2));
      expect(requests[0].url.path, '/3/tv/226680');
      expect(requests[0].url.queryParameters.containsKey('append_to_response'),
          isFalse);
      expect(requests[1].url.queryParameters['append_to_response'],
          'season/1,season/2,season/3');

      expect(result.fetchedSeasons, isNull); // tutte
      expect(result.episodes.map((e) => e.id.value), [-1001, -2001, -2002, -3001]);
    });

    test('serie: id negativo, fonte, stato e rete', () async {
      final show =
          (await clientWith(tmdbShowJson).fetchShowWithEpisodes(226680)).show;
      expect(show.id.value, -226680);
      expect(show.source.value, ShowSource.tmdb);
      expect(show.status.value, ShowStatus.running);
      expect(show.network.value, 'TV8');
    });

    test('episodi: date a inizio giornata, titoli mancanti, senza data',
        () async {
      final eps = {
        for (final e
            in (await clientWith(tmdbShowJson).fetchShowWithEpisodes(226680))
                .episodes)
          e.id.value: e,
      };
      expect(eps[-1001]!.airstamp.value, DateTime(2023, 5, 9));
      expect(eps[-1001]!.showId.value, -226680);
      expect(eps[-2002]!.name.value, 'Episodio 2');
      expect(eps[-3001]!.airstamp.value, isNull);
    });

    test('onlyRecentSeasons: solo le ultime 2 stagioni', () async {
      final requests = <http.Request>[];
      final result = await clientWith(tmdbShowJson, requests: requests)
          .fetchShowWithEpisodes(226680, onlyRecentSeasons: true);

      expect(requests[1].url.queryParameters['append_to_response'],
          'season/2,season/3');
      expect(result.fetchedSeasons, {2, 3});
      expect(result.episodes.map((e) => e.season.value).toSet(), {2, 3});
    });
  });

  test('mappatura stati TMDB', () {
    expect(tmdbStatus('Returning Series'), ShowStatus.running);
    expect(tmdbStatus('Ended'), ShowStatus.ended);
    expect(tmdbStatus('Canceled'), ShowStatus.ended);
    expect(tmdbStatus('In Production'), ShowStatus.inDevelopment);
    expect(tmdbStatus(null), ShowStatus.unknown);
  });

  test('401 -> TmdbException', () async {
    expect(
      () => clientWith('', status: 401).searchShows('x'),
      throwsA(isA<TmdbException>()
          .having((e) => e.statusCode, 'statusCode', 401)),
    );
  });
}
