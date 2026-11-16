import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../domain/enums.dart';
import '../formatters.dart';

/// Vero se l'episodio ha una data ed è già andato in onda.
bool isEpisodeAired(Episode episode, [DateTime? now]) {
  final air = episode.airstamp;
  return air != null && !air.isAfter(now ?? DateTime.now());
}

/// Riga di un episodio: icona di stato, codice + titolo, data.
class EpisodeTile extends StatelessWidget {
  const EpisodeTile({
    super.key,
    required this.episode,
    this.onTap,
    this.onLongPress,
    this.now,
  });

  final Episode episode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Solo per i test: permette di fissare "adesso".
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final air = episode.airstamp;
    final isAired = isEpisodeAired(episode, now);
    final number = episode.number;
    final code =
        number == null ? 'Speciale' : 'E${number.toString().padLeft(2, '0')}';

    final String subtitle;
    if (air == null) {
      subtitle = 'Data da annunciare';
    } else if (isAired) {
      subtitle = formatAirDate(air);
    } else {
      subtitle = 'In arrivo · ${formatAirDate(air)}';
    }

    final grey = Theme.of(context).disabledColor;
    final (IconData icon, Color? color) = switch (episode.watchStatus) {
      WatchStatus.watched => (Icons.check_circle, Theme.of(context).colorScheme.primary),
      WatchStatus.skipped => (Icons.do_not_disturb_on_outlined, grey),
      WatchStatus.toWatch =>
        isAired ? (Icons.radio_button_unchecked, null) : (Icons.schedule, grey),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text('$code · ${episode.name}'),
      subtitle: Text(subtitle),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
