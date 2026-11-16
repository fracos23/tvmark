import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Titoletto colorato che separa i gruppi di una lista.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

/// Lista vuota che supporta comunque il trascina-per-aggiornare.
class EmptyRefreshableList extends StatelessWidget {
  const EmptyRefreshableList({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
