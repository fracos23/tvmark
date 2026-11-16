import 'package:flutter_test/flutter_test.dart';
import 'package:tvmark/data/app_database.dart';
import 'package:tvmark/domain/enums.dart';
import 'package:tvmark/domain/home_sections.dart';

final now = DateTime(2026, 11, 16, 12);
const day = Duration(days: 1);

TvShow show(int id, String name, ShowStatus status) =>
    TvShow(id: id, name: name, status: status, addedAt: now);

ShowEpisode ep(
  TvShow s,
  int id, {
  required int season,
  required int number,
  Duration? fromNow,
  WatchStatus status = WatchStatus.toWatch,
}) =>
    ShowEpisode(
      s,
      Episode(
        id: id,
        showId: s.id,
        season: season,
        number: number,
        name: 'E$number',
        airstamp: fromNow == null ? null : now.add(fromNow),
        watchStatus: status,
        firstSeenAt: now,
      ),
    );

void main() {
  final fire = show(1, 'Chicago Fire', ShowStatus.running);
  final pd = show(2, 'Chicago PD', ShowStatus.running);
  final paused = show(3, 'In pausa', ShowStatus.running);
  final ended = show(4, 'Finita', ShowStatus.ended);

  final data = buildHomeData(
    shows: [fire, pd, paused, ended],
    now: now,
    episodes: [
      // Chicago Fire: 5 usciti da vedere (in disordine) + 2 futuri
      ep(fire, 15, season: 14, number: 5, fromNow: -day * 2),
      ep(fire, 11, season: 14, number: 1, fromNow: -day * 30),
      ep(fire, 13, season: 14, number: 3, fromNow: -day * 16),
      ep(fire, 12, season: 14, number: 2, fromNow: -day * 23),
      ep(fire, 14, season: 14, number: 4, fromNow: -day * 9),
      ep(fire, 17, season: 14, number: 7, fromNow: day * 14),
      ep(fire, 16, season: 14, number: 6, fromNow: day * 7),
      // Chicago PD: uno uscito da vedere + uno futuro + uno futuro saltato
      ep(pd, 21, season: 13, number: 1, fromNow: -day * 20),
      ep(pd, 22, season: 13, number: 2, fromNow: day * 2),
      ep(pd, 23, season: 13, number: 3, fromNow: day * 9,
          status: WatchStatus.skipped),
      // In pausa: solo un episodio senza data
      ep(paused, 31, season: 2, number: 1),
      // Finita: un vecchio episodio da vedere
      ep(ended, 41, season: 1, number: 10, fromNow: -day * 400),
    ],
  );

  test('Da vedere: dal più vecchio, al massimo 3 per serie', () {
    expect(data.toWatch.map((e) => (e.show.name, e.episode.number)), [
      ('Finita', 10),
      ('Chicago Fire', 1),
      ('Chicago Fire', 2),
      ('Chicago PD', 1),
      ('Chicago Fire', 3),
    ]);
  });

  test('Da vedere: conteggi nascosti e totali per serie', () {
    expect(data.hiddenByShow, {1: 2}); // Fire: 5 da vedere, 3 mostrati
    expect(data.toWatchCountByShow, {1: 5, 2: 1, 4: 1});
    expect(data.totalToWatch, 7);
  });

  test('In arrivo: tutti gli episodi futuri, dal più vicino, senza saltati',
      () {
    expect(data.upcoming.map((e) => (e.show.name, e.episode.number)), [
      ('Chicago PD', 2),
      ('Chicago Fire', 6),
      ('Chicago Fire', 7),
    ]);
  });

  test('Le mie serie: in corso, in pausa, concluse', () {
    expect(data.running.map((s) => s.name), ['Chicago Fire', 'Chicago PD']);
    expect(data.paused.map((s) => s.name), ['In pausa']);
    expect(data.ended.map((s) => s.name), ['Finita']);
  });

  test('episodi usciti ma già visti o saltati non sono "da vedere"', () {
    final d = buildHomeData(
      shows: [fire],
      now: now,
      episodes: [
        ep(fire, 1, season: 1, number: 1, fromNow: -day,
            status: WatchStatus.watched),
        ep(fire, 2, season: 1, number: 2, fromNow: -day,
            status: WatchStatus.skipped),
      ],
    );
    expect(d.toWatch, isEmpty);
    expect(d.totalToWatch, 0);
    expect(d.paused.map((s) => s.name), ['Chicago Fire']);
  });
}
