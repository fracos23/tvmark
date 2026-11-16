import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Locandina con segnaposto se manca l'immagine
/// o se il caricamento fallisce (es. offline).
class Poster extends StatelessWidget {
  const Poster({
    super.key,
    required this.url,
    this.width = 46,
    this.radius = 8,
  });

  final String? url;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.42;
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.raised,
      child: const Icon(Icons.tv, size: 20, color: AppColors.textMuted),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              // Decodifica l'immagine già alla dimensione mostrata:
              // meno memoria e meno lavoro mentre la lista scorre.
              cacheWidth:
                  (width * MediaQuery.devicePixelRatioOf(context)).round(),
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
