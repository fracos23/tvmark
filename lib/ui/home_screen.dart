import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/show_repository.dart';
import 'formatters.dart';
import 'search_screen.dart';
import 'show_detail_screen.dart';
import 'widgets/poster.dart';

/// Home provvisoria: elenco delle serie seguite con il numero di episodi
/// usciti e non ancora visti. Le sezioni "Usciti / In arrivo / In pausa"
/// arrivano nello sprint successivo, insieme al refresh.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final ShowRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<List<TvShow>> _shows = widget.repository.watchShows();
  late final Stream<Map<int, int>> _counts =
      widget.repository.watchAiredToWatchCounts();

  void _openSearch() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchScreen(repository: widget.repository),
        ),
      );

  void _openShow(TvShow show) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ShowDetailScreen(repository: widget.repository, show: show),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TVMark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Aggiungi serie',
            onPressed: _openSearch,
          ),
        ],
      ),
      body: StreamBuilder<List<TvShow>>(
        stream: _shows,
        builder: (context, showsSnap) {
          final shows = showsSnap.data;
          if (shows == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (shows.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nessuna serie seguita'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _openSearch,
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi una serie'),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<Map<int, int>>(
            stream: _counts,
            builder: (context, countsSnap) {
              final counts = countsSnap.data ?? const {};
              return ListView.separated(
                itemCount: shows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final show = shows[i];
                  final toWatch = counts[show.id] ?? 0;
                  return ListTile(
                    leading: Poster(url: show.imageUrl),
                    title: Text(show.name),
                    subtitle: Text([
                      if (show.network != null) show.network!,
                      show.status.label,
                    ].join(' · ')),
                    trailing: toWatch > 0
                        ? Badge.count(
                            count: toWatch,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => _openShow(show),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
