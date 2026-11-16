import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../domain/home_sections.dart';
import '../formatters.dart';
import '../theme.dart';
import '../widgets/section_header.dart';
import '../widgets/show_card.dart';
import '../widgets/watch_check.dart';

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
        // Key per episodio: vedi la nota in WatchCheck.
        key: ValueKey('to-watch-${item.episode.id}'),
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
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: children,
      ),
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({
    super.key,
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
    return ShowCard(
      posterUrl: item.show.imageUrl,
      title: item.show.name,
      lines: [
        CardText.primary('${episodeCode(ep)} · ${ep.name}'),
        CardText.muted('Uscito ${formatAirDate(ep.airstamp!)}'),
      ],
      trailing: WatchCheck(onChecked: onMarkWatched),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        // Allineato al testo delle card sopra.
        padding: EdgeInsets.fromLTRB(ShowCard.textInset(64), 4, 16, 10),
        child: Text(
          '$text ›',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
