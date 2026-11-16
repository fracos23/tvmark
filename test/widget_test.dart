import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tvmark/data/app_database.dart';
import 'package:tvmark/domain/enums.dart';
import 'package:tvmark/ui/widgets/episode_tile.dart';

final _now = DateTime(2026, 11, 16, 12);

Episode _episode({
  DateTime? airstamp,
  WatchStatus status = WatchStatus.toWatch,
  int? number = 8,
}) =>
    Episode(
      id: 1,
      showId: 1,
      season: 14,
      number: number,
      name: 'Titolo',
      airstamp: airstamp,
      watchStatus: status,
      firstSeenAt: _now,
    );

Future<void> _pump(WidgetTester tester, Episode ep) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EpisodeTile(episode: ep, now: _now)),
      ),
    );

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  testWidgets('episodio senza data: "Data da annunciare"', (tester) async {
    await _pump(tester, _episode());
    expect(find.text('E08 · Titolo'), findsOneWidget);
    expect(find.text('Data da annunciare'), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });

  testWidgets('episodio futuro: "In arrivo"', (tester) async {
    await _pump(tester, _episode(airstamp: _now.add(const Duration(days: 3))));
    expect(find.textContaining('In arrivo'), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });

  testWidgets('episodio uscito da vedere: cerchio vuoto, niente "In arrivo"',
      (tester) async {
    await _pump(
        tester, _episode(airstamp: _now.subtract(const Duration(days: 1))));
    expect(find.textContaining('In arrivo'), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('episodio visto: spunta', (tester) async {
    await _pump(
      tester,
      _episode(
        airstamp: _now.subtract(const Duration(days: 1)),
        status: WatchStatus.watched,
      ),
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('speciale senza numero', (tester) async {
    await _pump(tester, _episode(number: null));
    expect(find.text('Speciale · Titolo'), findsOneWidget);
  });

  test('isEpisodeAired', () {
    expect(isEpisodeAired(_episode(), _now), isFalse);
    expect(
        isEpisodeAired(
            _episode(airstamp: _now.subtract(const Duration(minutes: 1))),
            _now),
        isTrue);
    expect(
        isEpisodeAired(
            _episode(airstamp: _now.add(const Duration(minutes: 1))), _now),
        isFalse);
  });
}
