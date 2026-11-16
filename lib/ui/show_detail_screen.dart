import 'package:material_ui/material_ui.dart';

import '../data/app_database.dart';
import '../data/show_repository.dart';
import '../domain/enums.dart';
import 'formatters.dart';
import 'widgets/episode_tile.dart';

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
      appBar: AppBar(
        title: Text(widget.show.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Smetti di seguire',
            onPressed: _confirmUnfollow,
          ),
        ],
      ),
      body: StreamBuilder<List<Episode>>(
        stream: _episodes,
        builder: (context, snapshot) {
          final episodes = snapshot.data;
          if (episodes == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (episodes.isEmpty) {
            return const Center(child: Text('Nessun episodio disponibile'));
          }

          // Raggruppa per stagione, dalla prima all'ultima.
          final bySeason = <int, List<Episode>>{};
          for (final ep in episodes) {
            bySeason.putIfAbsent(ep.season, () => []).add(ep);
          }
          final seasons = bySeason.keys.toList()..sort();
          final now = DateTime.now();

          return ListView(
            children: [
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
            ],
          );
        },
      ),
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

    // Chiusa all'apertura (salvo arrivo da "In arrivo"); si apre al tap.
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Text('Stagione $season'),
      subtitle: Text('$watched/${episodes.length} visti'),
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
    );
  }
}
