import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../domain/home_sections.dart';
import '../formatters.dart';
import '../widgets/poster.dart';
import '../widgets/section_header.dart';

/// Pagina "In arrivo": tutti gli episodi futuri con data,
/// raggruppati per giorno come un calendario.
class UpcomingPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (data.upcoming.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const EmptyRefreshableList(
            message: 'Nessun episodio in programma'),
      );
    }

    final now = DateTime.now();
    final children = <Widget>[];
    DateTime? currentDay;

    for (final item in data.upcoming) {
      final air = item.episode.airstamp!;
      final local = air.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day != currentDay) {
        children.add(SectionHeader(formatDayHeader(air, now: now)));
        currentDay = day;
      }
      children.add(ListTile(
        leading: Poster(url: item.show.imageUrl),
        title: Text(item.show.name),
        subtitle:
            Text('${episodeCode(item.episode)} · ${item.episode.name}'),
        trailing: Text(formatTime(air)),
        onTap: () => onOpenShow(item.show),
      ));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [...children, const SizedBox(height: 24)],
      ),
    );
  }
}
