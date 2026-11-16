import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../domain/home_sections.dart';
import '../formatters.dart';
import '../widgets/poster.dart';
import '../widgets/section_header.dart';

/// Pagina "Da vedere": un episodio per riga, dal più vecchio,
/// al massimo 3 per serie (poi "+X altri episodi").
class ToWatchPage extends StatelessWidget {
  const ToWatchPage({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onOpenShow,
    required this.onMarkWatched,
  });

  final HomeData data;
  final Future<void> Function() onRefresh;
  final void Function(TvShow) onOpenShow;
  final void Function(Episode) onMarkWatched;

  @override
  Widget build(BuildContext context) {
    if (data.toWatch.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const EmptyRefreshableList(
            message: 'Sei in pari con tutte le serie'),
      );
    }

    // Quante righe mostriamo per ogni serie: serve a sapere dopo quale
    // episodio inserire la riga "+X altri".
    final shownPerShow = <int, int>{};
    for (final item in data.toWatch) {
      shownPerShow.update(item.show.id, (n) => n + 1, ifAbsent: () => 1);
    }

    final seen = <int, int>{};
    final children = <Widget>[];
    for (final item in data.toWatch) {
      final showId = item.show.id;
      children.add(_EpisodeRow(
        item: item,
        onTap: () => onOpenShow(item.show),
        onMarkWatched: () => onMarkWatched(item.episode),
      ));
      final count = seen.update(showId, (n) => n + 1, ifAbsent: () => 1);
      final hidden = data.hiddenByShow[showId] ?? 0;
      if (count == shownPerShow[showId] && hidden > 0) {
        children.add(_MoreRow(
          text: '+$hidden ${hidden == 1 ? 'altro episodio' : 'altri episodi'}'
              ' di ${item.show.name}',
          onTap: () => onOpenShow(item.show),
        ));
      }
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

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({
    required this.item,
    required this.onTap,
    required this.onMarkWatched,
  });

  final ShowEpisode item;
  final VoidCallback onTap;
  final VoidCallback onMarkWatched;

  @override
  Widget build(BuildContext context) {
    final ep = item.episode;
    return ListTile(
      leading: Poster(url: item.show.imageUrl),
      title: Text(item.show.name),
      subtitle: Text(
        '${episodeCode(ep)} · ${ep.name}\n'
        'Uscito ${formatAirDate(ep.airstamp!)}',
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        tooltip: 'Segna come visto',
        onPressed: onMarkWatched,
      ),
      onTap: onTap,
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      // Allineato al testo delle righe sopra (dopo la locandina).
      contentPadding: const EdgeInsets.only(left: 78, right: 16),
      title: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
