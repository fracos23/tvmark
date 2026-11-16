import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/show_repository.dart';
import '../data/tvmaze_client.dart';
import 'formatters.dart';
import 'widgets/poster.dart';

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
      final results = await widget.repository.search(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } on TvmazeException catch (e) {
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
    } on TvmazeException {
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
        bottom: _loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
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
                  'Dati forniti da TVmaze.com',
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
    if (_results.isEmpty) {
      final hasQuery = _controller.text.trim().isNotEmpty;
      return Center(
        child: Text(hasQuery && !_loading
            ? 'Nessun risultato'
            : 'Scrivi il nome di una serie'),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final show = _results[i];
        final year = show.premieredYear;
        final details = [
          if (show.network != null) show.network!,
          show.status.label,
        ].join(' · ');

        final Widget trailing;
        if (followedIds.contains(show.id)) {
          trailing = const Icon(Icons.check, color: Colors.green);
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
          leading: Poster(url: show.imageUrl, width: 40),
          title: Text(year == null ? show.name : '${show.name} ($year)'),
          subtitle: Text(details),
          trailing: trailing,
        );
      },
    );
  }
}
