import 'package:flutter_test/flutter_test.dart';

import 'package:tvmark/main.dart';

void main() {
  testWidgets('La home si avvia con il titolo TVMark', (tester) async {
    await tester.pumpWidget(const TvMarkApp());

    expect(find.text('TVMark'), findsOneWidget);
    expect(find.text('Nessuna serie seguita'), findsOneWidget);
  });
}
