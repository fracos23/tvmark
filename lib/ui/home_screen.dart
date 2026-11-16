import 'package:material_ui/material_ui.dart';

import '../data/app_database.dart';
import '../data/show_repository.dart';
import '../data/tvmaze_client.dart';
import '../domain/enums.dart';
import '../domain/home_sections.dart';
import 'pages/my_shows_page.dart';
import 'pages/to_watch_page.dart';
import 'pages/upcoming_page.dart';
import 'search_screen.dart';
import 'show_detail_screen.dart';

/// Schermata principale: tre pagine navigabili dalla bottom bar.
/// Gestisce anche il refresh da TVmaze: all'apertura, al ritorno in
/// primo piano e con il trascina-per-aggiornare in ogni pagina.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final ShowRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _titles = ['Da vedere', 'In arrivo', 'Le mie serie'];

  late final Stream<List<TvShow>> _shows = widget.repository.watchShows();
  late final Stream<List<ShowEpisode>> _episodes =
      widget.repository.watchRelevantEpisodes();

  /// Ritorno in primo piano (app riaperta dal multitasking):
  /// iOS non riavvia l'app, quindi initState non basterebbe.
  late final AppLifecycleListener _lifecycle;

  int _tab = 0;
  bool _refreshing = false;

  ShowRepository get _repo => widget.repository;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool force = false}) async {
    if (mounted) setState(() => _refreshing = true);
    try {
      await _repo.refresh(force: force);
    } on TvmazeException {
      // Automatico: silenzioso (es. offline). Manuale: avvisiamo.
      if (force && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Aggiornamento non riuscito: mostro gli ultimi dati salvati.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _forceRefresh() => _refresh(force: true);

  void _openSearch() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchScreen(repository: _repo)),
      );

  void _openShow(TvShow show, {bool expandUpcoming = false}) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShowDetailScreen(
            repository: _repo,
            show: show,
            expandUpcoming: expandUpcoming,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TvShow>>(
      stream: _shows,
      builder: (context, showsSnap) {
        return StreamBuilder<List<ShowEpisode>>(
          stream: _episodes,
          builder: (context, epSnap) {
            final shows = showsSnap.data;
            final data = shows == null
                ? null
                : buildHomeData(
                    shows: shows,
                    episodes: epSnap.data ?? const [],
                    now: DateTime.now(),
                  );
            return _buildScaffold(shows, data);
          },
        );
      },
    );
  }

  Widget _buildScaffold(List<TvShow>? shows, HomeData? data) {
    final Widget body;
    if (shows == null || data == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (shows.isEmpty) {
      body = _EmptyState(onAdd: _openSearch);
    } else {
      // IndexedStack: le tre pagine restano "vive", quindi cambiando tab
      // non si perde la posizione di scorrimento.
      body = IndexedStack(
        index: _tab,
        children: [
          ToWatchPage(
            data: data,
            onRefresh: _forceRefresh,
            onOpenShow: _openShow,
            onMarkWatched: (ep) =>
                _repo.markStatus(ep.id, WatchStatus.watched),
          ),
          UpcomingPage(
            data: data,
            onRefresh: _forceRefresh,
            // Da "In arrivo" apriamo la serie con gli episodi futuri in vista.
            onOpenShow: (show) => _openShow(show, expandUpcoming: true),
          ),
          MyShowsPage(
            data: data,
            onRefresh: _forceRefresh,
            onOpenShow: _openShow,
          ),
        ],
      );
    }

    final toWatchTotal = data?.totalToWatch ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Aggiungi serie',
            onPressed: _openSearch,
          ),
        ],
        bottom: _refreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: Badge.count(
              count: toWatchTotal,
              isLabelVisible: toWatchTotal > 0,
              child: const Icon(Icons.play_circle_outline),
            ),
            selectedIcon: Badge.count(
              count: toWatchTotal,
              isLabelVisible: toWatchTotal > 0,
              child: const Icon(Icons.play_circle),
            ),
            label: 'Da vedere',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'In arrivo',
          ),
          const NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Le mie serie',
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nessuna serie seguita'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi una serie'),
          ),
        ],
      ),
    );
  }
}
