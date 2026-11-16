import '../data/app_database.dart';
import 'enums.dart';

/// Un episodio insieme alla sua serie.
class ShowEpisode {
  const ShowEpisode(this.show, this.episode);

  final TvShow show;
  final Episode episode;
}

/// Tutto quello che serve alle tre pagine della home.
class HomeData {
  const HomeData({
    required this.toWatch,
    required this.hiddenByShow,
    required this.toWatchCountByShow,
    required this.upcoming,
    required this.upcomingLater,
    required this.laterCountByShow,
    required this.nextByShow,
    required this.running,
    required this.paused,
    required this.ended,
  });

  /// Episodi usciti e da vedere, dal più vecchio, al massimo N per serie.
  final List<ShowEpisode> toWatch;

  /// Per serie: quanti episodi da vedere sono stati nascosti dal limite.
  final Map<int, int> hiddenByShow;

  /// Per serie: totale episodi usciti da vedere (per i badge).
  final Map<int, int> toWatchCountByShow;

  /// Episodi futuri con data entro la finestra (default 7 giorni),
  /// dal più vicino.
  final List<ShowEpisode> upcoming;

  /// Episodi futuri con data oltre la finestra, dal più vicino.
  final List<ShowEpisode> upcomingLater;

  /// Per serie: quanti episodi in programma oltre la finestra.
  final Map<int, int> laterCountByShow;

  /// Per serie: il prossimo episodio con data (anche oltre la finestra).
  final Map<int, Episode> nextByShow;

  /// Serie non concluse con almeno un episodio futuro con data.
  final List<TvShow> running;

  /// Serie non concluse senza episodi futuri con data.
  final List<TvShow> paused;

  /// Serie concluse.
  final List<TvShow> ended;

  int get totalToWatch =>
      toWatchCountByShow.values.fold(0, (sum, n) => sum + n);
}

/// Ordine "di visione": data di uscita, poi stagione e numero.
int _compareEpisodes(Episode a, Episode b) {
  final byAir = a.airstamp!.compareTo(b.airstamp!);
  if (byAir != 0) return byAir;
  final bySeason = a.season.compareTo(b.season);
  if (bySeason != 0) return bySeason;
  return (a.number ?? 0).compareTo(b.number ?? 0);
}

int _compareShowEpisodes(ShowEpisode a, ShowEpisode b) {
  final c = _compareEpisodes(a.episode, b.episode);
  return c != 0 ? c : a.show.name.compareTo(b.show.name);
}

/// Funzione pura: dati serie + episodi rilevanti e l'ora attuale,
/// calcola il contenuto delle pagine. Testabile senza database né UI.
HomeData buildHomeData({
  required List<TvShow> shows,
  required List<ShowEpisode> episodes,
  required DateTime now,
  int maxPerShow = 3,
  Duration upcomingWindow = const Duration(days: 7),
}) {
  final upcomingLimit = now.add(upcomingWindow);
  final showsById = {for (final s in shows) s.id: s};
  final airedByShow = <int, List<Episode>>{};
  final upcoming = <ShowEpisode>[];
  final upcomingLater = <ShowEpisode>[];
  final showsWithUpcoming = <int>{};

  for (final item in episodes) {
    final show = showsById[item.show.id];
    final air = item.episode.airstamp;
    if (show == null || air == null) continue;

    if (!air.isAfter(now)) {
      if (item.episode.watchStatus == WatchStatus.toWatch) {
        airedByShow.putIfAbsent(show.id, () => []).add(item.episode);
      }
    } else {
      // Conta per "In corso" anche se è oltre la finestra (es. a gennaio).
      showsWithUpcoming.add(show.id);
      // Un episodio futuro segnato "saltato" non interessa nel calendario.
      if (item.episode.watchStatus != WatchStatus.skipped) {
        final target = air.isAfter(upcomingLimit) ? upcomingLater : upcoming;
        target.add(ShowEpisode(show, item.episode));
      }
    }
  }

  final toWatch = <ShowEpisode>[];
  final hidden = <int, int>{};
  final counts = <int, int>{};
  for (final MapEntry(key: showId, value: list) in airedByShow.entries) {
    list.sort(_compareEpisodes);
    counts[showId] = list.length;
    final show = showsById[showId]!;
    toWatch.addAll(list.take(maxPerShow).map((e) => ShowEpisode(show, e)));
    if (list.length > maxPerShow) hidden[showId] = list.length - maxPerShow;
  }
  toWatch.sort(_compareShowEpisodes);
  upcoming.sort(_compareShowEpisodes);
  upcomingLater.sort(_compareShowEpisodes);

  final laterCount = <int, int>{};
  for (final item in upcomingLater) {
    laterCount.update(item.show.id, (n) => n + 1, ifAbsent: () => 1);
  }
  // Liste già ordinate e "upcoming" viene prima di "later":
  // il primo episodio incontrato per ogni serie è il più vicino.
  final next = <int, Episode>{};
  for (final item in [...upcoming, ...upcomingLater]) {
    next.putIfAbsent(item.show.id, () => item.episode);
  }

  return HomeData(
    toWatch: toWatch,
    hiddenByShow: hidden,
    toWatchCountByShow: counts,
    upcoming: upcoming,
    upcomingLater: upcomingLater,
    laterCountByShow: laterCount,
    nextByShow: next,
    running: [
      for (final s in shows)
        if (s.status != ShowStatus.ended && showsWithUpcoming.contains(s.id)) s,
    ],
    paused: [
      for (final s in shows)
        if (s.status != ShowStatus.ended && !showsWithUpcoming.contains(s.id))
          s,
    ],
    ended: [
      for (final s in shows)
        if (s.status == ShowStatus.ended) s,
    ],
  );
}
