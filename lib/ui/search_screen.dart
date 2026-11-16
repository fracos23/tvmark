import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/app_database.dart';
import '../data/show_repository.dart';
import '../data/tvmaze_client.dart';
import '../domain/enums.dart';
import 'formatters.dart';
import 'widgets/poster.dart';
import 'widgets/section_header.dart';

/// Ricerca su TVmaze e aggiunta di una serie alle seguite.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.repository});

  final ShowRepository repository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  /// Creato una volta sola: se lo creassimo in build(), ogni setState
  /// riaprirebbe la query sul database.
  late final Stream<List<TvShow>> _followed = widget.repository.watchShows();

  Timer? _debounce;
  int _requestId = 0;
  List<ShowSearchResult> _results = const [];

  /// Risultati TMDB non già presenti in [_results].
  List<ShowSearchResult> _extra = const [];
  bool _extraFailed = false;
  bool _loading = false;
  String? _error;
  final Set<int> _adding = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Debounce: cerca solo quando smetti di scrivere per 500 ms,
  /// così non si fa una chiamata a ogni lettera (rate limit di TVmaze).
  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(text));
  }

  Future<void> _search(String query) async {
    // Ogni ricerca ha un numero: se arriva la risposta di una ricerca
    // vecchia dopo una più recente, la ignoriamo.
    final id = ++_requestId;
    if (query.trim().isEmpty) {
      setState(() {
        _results = const [];
        _extra = const [];
        _extraFailed = false;
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await widget.repository.searchAll(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results.primary;
        _extra = results.secondary;
        _extraFailed = results.secondaryFailed;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = e.isRateLimited
            ? 'Troppe ricerche ravvicinate, riprova tra qualche secondo.'
            : 'Ricerca non riuscita. Controlla la connessione.';
        _loading = false;
      });
    }
  }

  Future<void> _follow(ShowSearchResult show) async {
    setState(() => _adding.add(show.id));
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.repository.followShow(show.id);
      messenger.showSnackBar(SnackBar(
        content: Text(
            '${show.name} aggiunta. Aprila per segnare a che episodio sei.'),
      ));
    } on ApiException {
      messenger.showSnackBar(SnackBar(
        content: Text('Non sono riuscito ad aggiungere ${show.name}. Riprova.'),
      ));
    } finally {
      if (mounted) setState(() => _adding.remove(show.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cerca una serie',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: (text) {
            _debounce?.cancel();
            _search(text);
          },
        ),
        // La barra c'è sempre (alta 2 px) e cambia solo il contenuto:
        // se comparisse/sparisse, Flutter ricostruirebbe l'AppBar e il
        // campo di testo al suo interno, perdendo le lettere digitate.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _loading
              ? const LinearProgressIndicator(minHeight: 2)
              : const SizedBox(height: 2),
        ),
      ),
      body: StreamBuilder<List<TvShow>>(
        stream: _followed,
        builder: (context, snapshot) {
          final followedIds = <int>{
            for (final s in snapshot.data ?? const <TvShow>[]) s.id,
          };
          return Column(
            children: [
              Expanded(child: _buildResults(followedIds)),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  widget.repository.tmdbEnabled
                      ? 'Dati: TVmaze.com e TMDB. Questo prodotto usa l\'API '
                          'TMDB ma non è approvato né certificato da TMDB.'
                      : 'Dati forniti da TVmaze.com',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResults(Set<int> followedIds) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_results.isEmpty && _extra.isEmpty) {
      final hasQuery = _controller.text.trim().isNotEmpty;
      return Center(
        child: Text(hasQuery && !_loading
            ? 'Nessun risultato'
            : 'Scrivi il nome di una serie'),
      );
    }

    return ListView(
      children: [
        for (final show in _results) _resultTile(show, followedIds),
        if (_extra.isNotEmpty) ...[
          const SectionHeader('Altri risultati da TMDB'),
          for (final show in _extra) _resultTile(show, followedIds),
        ],
        if (_extraFailed)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ricerca su TMDB non riuscita: mostro solo i risultati TVmaze.',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _resultTile(ShowSearchResult show, Set<int> followedIds) {
    final year = show.premieredYear;
    final details = show.source == ShowSource.tmdb
        // La ricerca TMDB non dà rete e stato: mostriamo paese e fonte.
        ? [if (show.originCountry != null) show.originCountry!, 'TMDB']
            .join(' · ')
        : [if (show.network != null) show.network!, show.status.label]
            .join(' · ');

    final Widget trailing;
    if (followedIds.contains(show.id)) {
      trailing =
          Icon(Icons.check, color: Theme.of(context).colorScheme.primary);
    } else if (_adding.contains(show.id)) {
      trailing = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      trailing = IconButton(
        icon: const Icon(Icons.add_circle_outline),
        tooltip: 'Segui',
        onPressed: () => _follow(show),
      );
    }

    return ListTile(
      leading: Poster(url: show.imageUrl, width: 40, radius: 6),
      title: Text(year == null ? show.name : '${show.name} ($year)'),
      subtitle: Text(details),
      trailing: trailing,
    );
  }
}
