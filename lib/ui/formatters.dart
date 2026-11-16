import 'package:intl/intl.dart';

import '../domain/enums.dart';

final _airDateFormat = DateFormat('EEE d MMM yyyy, HH:mm', 'it_IT');

/// Data di messa in onda nel fuso orario del telefono, in italiano.
/// Es. "gio 4 dic 2026, 03:00".
String formatAirDate(DateTime airstamp) =>
    _airDateFormat.format(airstamp.toLocal());

extension ShowStatusLabel on ShowStatus {
  String get label => switch (this) {
        ShowStatus.running => 'In corso',
        ShowStatus.ended => 'Conclusa',
        ShowStatus.toBeDetermined => 'Da definire',
        ShowStatus.inDevelopment => 'In sviluppo',
        ShowStatus.unknown => 'Stato sconosciuto',
      };
}
