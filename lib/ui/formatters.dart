import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../domain/enums.dart';

final _airDateFormat = DateFormat('EEE d MMM yyyy, HH:mm', 'it_IT');

/// Data di messa in onda nel fuso orario del telefono, in italiano.
/// Es. "gio 4 dic 2026, 03:00".
String formatAirDate(DateTime airstamp) =>
    _airDateFormat.format(airstamp.toLocal());

final _timeFormat = DateFormat('HH:mm', 'it_IT');

final _dayHeaderFormat = DateFormat('EEEE d MMMM', 'it_IT');

/// Giorni di calendario tra oggi e la data (0 = oggi, 1 = domani...).
int _daysFromToday(DateTime local, DateTime now) {
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  // round(): con il cambio dell'ora legale un "giorno" può durare 23 o 25 ore.
  return (day.difference(today).inHours / 24).round();
}

/// Solo l'ora, nel fuso del telefono: "21:00".
String formatTime(DateTime airstamp) => _timeFormat.format(airstamp.toLocal());

/// Intestazione di un giorno nel calendario:
/// "Oggi", "Domani", altrimenti "Giovedì 4 dicembre".
String formatDayHeader(DateTime airstamp, {DateTime? now}) {
  final local = airstamp.toLocal();
  final days = _daysFromToday(local, now ?? DateTime.now());
  if (days == 0) return 'Oggi';
  if (days == 1) return 'Domani';
  final text = _dayHeaderFormat.format(local);
  return text[0].toUpperCase() + text.substring(1);
}

final _shortDateFormat = DateFormat('EEE d MMM', 'it_IT');

/// Data breve per il prossimo episodio: "oggi", "domani", "gio 20 nov".
String formatNextDate(DateTime airstamp, {DateTime? now}) {
  final local = airstamp.toLocal();
  final days = _daysFromToday(local, now ?? DateTime.now());
  if (days == 0) return 'oggi, ${_timeFormat.format(local)}';
  if (days == 1) return 'domani, ${_timeFormat.format(local)}';
  return _shortDateFormat.format(local);
}

/// "S14E08", oppure "S14 Speciale" per gli episodi senza numero.
String episodeCode(Episode ep) {
  final season = 'S${ep.season.toString().padLeft(2, '0')}';
  final number = ep.number;
  return number == null
      ? '$season Speciale'
      : '${season}E${number.toString().padLeft(2, '0')}';
}

extension ShowStatusLabel on ShowStatus {
  String get label => switch (this) {
        ShowStatus.running => 'In corso',
        ShowStatus.ended => 'Conclusa',
        ShowStatus.toBeDetermined => 'Da definire',
        ShowStatus.inDevelopment => 'In sviluppo',
        ShowStatus.unknown => 'Stato sconosciuto',
      };
}
