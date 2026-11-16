import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'poster.dart';

/// Card arrotondata semitrasparente con locandina a sinistra,
/// titolo, righe di testo e un elemento opzionale a destra.
class ShowCard extends StatelessWidget {
  const ShowCard({
    super.key,
    required this.posterUrl,
    required this.title,
    this.lines = const [],
    this.trailing,
    this.onTap,
    this.posterWidth = 64,
  });

  final String? posterUrl;
  final String title;
  final List<Widget> lines;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double posterWidth;

  /// Distanza dal bordo sinistro dello schermo al testo della card:
  /// margine (14) + padding (10) + locandina + spazio (14).
  static double textInset(double posterWidth) => 14 + 10 + posterWidth + 14;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Poster(url: posterUrl, width: posterWidth, radius: 12),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      for (final line in lines)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: line,
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Testi standard dentro una [ShowCard].
abstract final class CardText {
  /// Riga principale: "S14E06 · Titolo".
  static Widget primary(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      );

  /// Riga secondaria grigia: date, rete...
  static Widget muted(String text) => Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      );

  /// Riga in ambra: "+3 in programma".
  static Widget accent(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      );
}
