import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../domain/home_sections.dart';
import '../formatters.dart';
import '../widgets/poster.dart';
import '../widgets/section_header.dart';

/// Pagina "Le mie serie": tutte le serie seguite, divise per stato.
/// "NBC · Prossimo: S14E08, gio 20 nov".
String _nextLabel(TvShow show, Episode? next) {
  final parts = [
    if (show.network != null) show.network!,
    if (next != null)
      'Prossimo: ${episodeCode(next)}, ${formatNextDate(next.airstamp!)}'
    else
      show.status.label,
  ];
  return parts.join(' · ');
}

class MyShowsPage extends StatelessWidget {
  const MyShowsPage({
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
    Widget tile(TvShow show, String subtitle) {
      final toWatch = data.toWatchCountByShow[show.id] ?? 0;
      return ListTile(
        leading: Poster(url: show.imageUrl),
        title: Text(show.name),
        subtitle: Text(subtitle),
        trailing: toWatch > 0
            ? Badge.count(
                count: toWatch,
                backgroundColor: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () => onOpenShow(show),
      );
    }

    String network(TvShow s, String fallback) => s.network ?? fallback;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (data.running.isNotEmpty) ...[
            SectionHeader('In corso (${data.running.length})'),
            for (final s in data.running)
              tile(s, _nextLabel(s, data.nextByShow[s.id])),
          ],
          if (data.paused.isNotEmpty) ...[
            SectionHeader('In pausa (${data.paused.length})'),
            for (final s in data.paused)
              tile(s, '${network(s, s.status.label)} · prossimo episodio non annunciato'),
          ],
          if (data.ended.isNotEmpty) ...[
            SectionHeader('Concluse (${data.ended.length})'),
            for (final s in data.ended) tile(s, network(s, s.status.label)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
