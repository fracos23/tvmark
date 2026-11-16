import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../data/app_database.dart';
import '../data/show_repository.dart';
import '../domain/enums.dart';
import 'formatters.dart';
import 'theme.dart';
import 'widgets/episode_tile.dart';
import 'widgets/poster.dart';

/// Dettaglio di una serie: stagioni (dalla prima, chiuse) ed episodi.
/// Tap su un episodio uscito: visto <-> da vedere.
/// Pressione lunga: tutte le azioni, incluso "Segna visti fino a qui".
class ShowDetailScreen extends StatefulWidget {
  const ShowDetailScreen({
    super.key,
    required this.repository,
    required this.show,
    this.expandUpcoming = false,
  });

  final ShowRepository repository;
  final TvShow show;

  /// Se true, all'apertura sono già espanse le stagioni con episodi futuri.
  final bool expandUpcoming;

  @override
  State<ShowDetailScreen> createState() => _ShowDetailScreenState();
}

class _ShowDetailScreenState extends State<ShowDetailScreen> {
  late final Stream<List<Episode>> _episodes =
      widget.repository.watchEpisodesOf(widget.show.id);

  ShowRepository get _repo => widget.repository;

  Future<void> _confirmUnfollow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Smettere di seguire?'),
        content: Text(
            '${widget.show.name} e lo stato di tutti i suoi episodi verranno eliminati.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _repo.unfollowShow(widget.show.id);
    if (mounted) Navigator.pop(context);
  }

  /// True se [e] viene prima di [target] nell'ordine della serie.
  /// Stessa regola di markWatchedUpTo: nella stessa stagione contano solo
  /// gli episodi con numero (gli speciali senza numero restano fuori).
  static bool _isBefore(Episode e, Episode target) {
    if (e.season != target.season) return e.season < target.season;
    final n = e.number;
    final t = target.number;
    return n != null && t != null && n < t;
  }

  /// Tap su un episodio uscito:
  /// - già visto -> torna "da vedere";
  /// - nessun precedente da vedere -> segnato visto subito;
  /// - altrimenti chiede se segnare anche i precedenti.
  void _onTapEpisode(Episode ep, List<Episode> all) {
    if (ep.watchStatus == WatchStatus.watched) {
      _repo.markStatus(ep.id, WatchStatus.toWatch);
      return;
    }
    final earlier = all
        .where((e) => e.watchStatus == WatchStatus.toWatch && _isBefore(e, ep))
        .length;
    if (earlier == 0) {
      _repo.markStatus(ep.id, WatchStatus.watched);
    } else {
      _askMarkPrevious(ep, earlier);
    }
  }

  Future<void> _askMarkPrevious(Episode ep, int earlier) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                earlier == 1
                    ? 'C\'è 1 episodio precedente non visto'
                    : 'Ci sono $earlier episodi precedenti non visti',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              subtitle: Text('Stai segnando ${episodeCode(ep)} · ${ep.name}'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Segna visti fino a qui'),
              subtitle: Text(earlier == 1
                  ? 'Questo e il precedente'
                  : 'Questo e i $earlier precedenti'),
              onTap: () {
                Navigator.pop(ctx);
                _repo.markWatchedUpTo(ep);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Solo questo episodio'),
              onTap: () {
                Navigator.pop(ctx);
                _repo.markStatus(ep.id, WatchStatus.watched);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEpisodeActions(Episode ep) {
    void run(BuildContext sheetContext, Future<void> Function() action) {
      Navigator.pop(sheetContext);
      action();
    }

    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(ep.name,
                  style: Theme.of(ctx).textTheme.titleMedium),
              subtitle: Text(
                  'Stagione ${ep.season}${ep.number == null ? '' : ', episodio ${ep.number}'}'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Visto'),
              onTap: () =>
                  run(ctx, () => _repo.markStatus(ep.id, WatchStatus.watched)),
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('Da vedere'),
              onTap: () =>
                  run(ctx, () => _repo.markStatus(ep.id, WatchStatus.toWatch)),
            ),
            ListTile(
              leading: const Icon(Icons.do_not_disturb_on_outlined),
              title: const Text('Saltato'),
              onTap: () =>
                  run(ctx, () => _repo.markStatus(ep.id, WatchStatus.skipped)),
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Segna visti fino a qui'),
              subtitle:
                  const Text('Tutti i precedenti "da vedere" diventano visti'),
              onTap: () => run(ctx, () => _repo.markWatchedUpTo(ep)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Episode>>(
        stream: _episodes,
        builder: (context, snapshot) {
          final episodes = snapshot.data;
          final list = episodes ?? const <Episode>[];

          // Raggruppa per stagione, dalla prima all'ultima.
          final bySeason = <int, List<Episode>>{};
          for (final ep in list) {
            bySeason.putIfAbsent(ep.season, () => []).add(ep);
          }
          final seasons = bySeason.keys.toList()..sort();
          final now = DateTime.now();

          final aired = list.where((e) => isEpisodeAired(e, now)).length;
          final watched =
              list.where((e) => e.watchStatus == WatchStatus.watched).length;

          return CustomScrollView(
            slivers: [
              _ShowHeader(
                show: widget.show,
                watched: watched,
                aired: aired,
                onUnfollow: _confirmUnfollow,
              ),
              if (episodes == null)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (episodes.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Nessun episodio disponibile')),
                )
              else
                SliverList.list(children: [
                  const SizedBox(height: 8),
                  for (final season in seasons)
                    _SeasonSection(
                      // La key mantiene aperto/chiuso quando i dati cambiano.
                      key: PageStorageKey('season-$season'),
                      season: season,
                      episodes: bySeason[season]!,
                      initiallyExpanded: widget.expandUpcoming &&
                          bySeason[season]!.any((e) =>
                              e.airstamp != null && e.airstamp!.isAfter(now)),
                      onMarkSeasonWatched: () =>
                          _repo.markSeasonWatched(widget.show.id, season),
                      onTapEpisode: (ep) => _onTapEpisode(ep, episodes),
                      onLongPressEpisode: _showEpisodeActions,
                    ),
                  const SizedBox(height: 32),
                ]),
            ],
          );
        },
      ),
    );
  }
}

/// Intestazione che si chiude scorrendo: da espansa mostra locandina,
/// nome, rete/stato e avanzamento; da chiusa solo il nome nella barra.
class _ShowHeader extends StatelessWidget {
  const _ShowHeader({
    required this.show,
    required this.watched,
    required this.aired,
    required this.onUnfollow,
  });

  final TvShow show;
  final int watched;
  final int aired;
  final VoidCallback onUnfollow;

  static const _expandedHeight = 290.0;
  static const _toolbarHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final minHeight = _toolbarHeight + topPadding;
    final maxHeight = _expandedHeight + topPadding;

    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
      toolbarHeight: _toolbarHeight,
      backgroundColor: AppColors.background,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Smetti di seguire',
          onPressed: onUnfollow,
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // t = 1 intestazione aperta, 0 chiusa.
          final t = ((constraints.maxHeight - minHeight) /
                  (maxHeight - minHeight))
              .clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: t,
                child: _HeaderContent(
                  show: show,
                  watched: watched,
                  aired: aired,
                ),
              ),
              // Nome nella barra, visibile solo quando è chiusa.
              Positioned(
                left: 56,
                right: 56,
                bottom: 0,
                height: _toolbarHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: (1 - t * 2).clamp(0.0, 1.0),
                    child: Text(
                      show.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
    required this.show,
    required this.watched,
    required this.aired,
  });

  final TvShow show;
  final int watched;
  final int aired;

  @override
  Widget build(BuildContext context) {
    final url = show.imageUrl;
    final progress = aired == 0 ? 0.0 : (watched / aired).clamp(0.0, 1.0);
    final meta = [
      if (show.network != null) show.network!,
      show.status.label,
    ].join(' · ');

    return Stack(
      fit: StackFit.expand,
      children: [
        // Sfondo: la locandina ingrandita e sfocata, molto scurita.
        if (url != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Opacity(
              opacity: 0.45,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                cacheWidth: 200,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        // Sfumatura verso il nero, così si fonde con la lista sotto.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x660E0E10), AppColors.background],
              stops: [0.0, 0.95],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Poster(url: url, width: 104, radius: 14),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      show.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.raised,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      aired == 0
                          ? 'Nessun episodio ancora uscito'
                          : '$watched di $aired episodi usciti visti',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeasonSection extends StatelessWidget {
  const _SeasonSection({
    super.key,
    required this.season,
    required this.episodes,
    required this.initiallyExpanded,
    required this.onMarkSeasonWatched,
    required this.onTapEpisode,
    required this.onLongPressEpisode,
  });

  final int season;
  final List<Episode> episodes;
  final bool initiallyExpanded;
  final VoidCallback onMarkSeasonWatched;
  final void Function(Episode) onTapEpisode;
  final void Function(Episode) onLongPressEpisode;

  @override
  Widget build(BuildContext context) {
    final watched =
        episodes.where((e) => e.watchStatus == WatchStatus.watched).length;
    final complete = watched == episodes.length;

    // Card come nel resto dell'app. Chiusa all'apertura (salvo arrivo
    // da "In arrivo"); si apre al tap.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            'Stagione $season',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            complete ? 'Completata' : '$watched/${episodes.length} visti',
            style: TextStyle(
              fontSize: 13,
              color: complete ? AppColors.accent : AppColors.textMuted,
            ),
          ),
          trailing: PopupMenuButton<void>(
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: onMarkSeasonWatched,
                child: const Text('Segna stagione come vista'),
              ),
            ],
          ),
          children: [
            for (final ep in episodes)
              EpisodeTile(
                episode: ep,
                // Il tap rapido vale solo per gli episodi già usciti.
                onTap: isEpisodeAired(ep) ? () => onTapEpisode(ep) : null,
                onLongPress: () => onLongPressEpisode(ep),
              ),
          ],
        ),
      ),
    );
  }
}
