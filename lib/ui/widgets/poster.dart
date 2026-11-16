import 'package:flutter/material.dart';

/// Locandina piccola per le liste, con segnaposto se manca l'immagine
/// o se il caricamento fallisce (es. offline).
class Poster extends StatelessWidget {
  const Poster({super.key, required this.url, this.width = 46});

  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.tv, size: 20),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
