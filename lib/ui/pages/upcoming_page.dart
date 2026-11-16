import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../domain/home_sections.dart';
import '../formatters.dart';
import '../widgets/poster.dart';
import '../widgets/section_header.dart';

/// Pagina "In arrivo": episodi dei prossimi 7 giorni, raggruppati per giorno
/// come un calendario. Ogni serie con altri episodi in programma mostra
/// "+N in programma"; il tap apre la serie con gli episodi futuri in vista.
/// In fondo, un pulsante espande sul posto tutto il calendario futuro.
class UpcomingPage extends StatefulWidget {
  const UpcomingPage({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onOpenShow,
  });

  final HomeData data;
  final Future<void> Function() onRefresh;
  final void Function(TvShow) onOpenShow;

  @override
  State<UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  bool _showLater = false;

  /// Righe raggruppate per giorno: un'intestazione a ogni cambio di data.
  /// Se [laterHints] è true, sull'ultima riga di ogni serie compare
  /// "+N in programma" quando quella serie ha episodi oltre la settimana.
  List<Widget> _dayGroups(
    List<ShowEpisode> items,
    DateTime now, {
    required bool laterHints,
  }) {
    final lastIndexByShow = <int, int>{
      for (var i = 0; i < items.length; i++) items[i].show.id: i,
    };
    final primary = Theme.of(context).colorScheme.primary;

    final children = <Widget>[];
    DateTime? currentDay;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final air = item.episode.airstamp!;
      final local = air.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day != currentDay) {
        children.add(SectionHeader(formatDayHeader(air, now: now)));
        currentDay = day;
      }

      final later = widget.data.laterCountByShow[item.show.id] ?? 0;
      final showHint = laterHints && later > 0 && lastIndexByShow[item.show.id] == i;

      children.add(ListTile(
        leading: Poster(url: item.show.imageUrl),
        title: Text(item.show.name),
        subtitle: Text.rich(TextSpan(children: [
          TextSpan(text: '${episodeCode(item.episode)} · ${item.episode.name}'),
          if (showHint)
            TextSpan(
              text: '\n+$later in programma',
              style: TextStyle(color: primary),
            ),
        ])),
        isThreeLine: showHint,
        trailing: Text(formatTime(air)),
        onTap: () => widget.onOpenShow(item.show),
      ));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final week = widget.data.upcoming;
    final later = widget.data.upcomingLater;
    final now = DateTime.now();

    if (week.isEmpty && later.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: const EmptyRefreshableList(
            message: 'Nessun episodio in programma'),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (week.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 48, 24, 8),
              child: Text(
                'Nessun episodio nei prossimi 7 giorni',
                textAlign: TextAlign.center,
              ),
            ),
          // Espansa: un unico raggruppamento, così un giorno a cavallo
          // della finestra non ha l'intestazione ripetuta.
          ..._dayGroups(
            _showLater ? [...week, ...later] : week,
            now,
            // Da espansa vedi già tutto: il "+N" sarebbe ridondante.
            laterHints: !_showLater,
          ),
          if (later.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showLater = !_showLater),
                  icon: Icon(
                      _showLater ? Icons.expand_less : Icons.expand_more),
                  label: Text(_showLater
                      ? 'Mostra meno'
                      : 'Mostra altri ${later.length} '
                          '${later.length == 1 ? 'episodio' : 'episodi'} '
                          'in programma'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
