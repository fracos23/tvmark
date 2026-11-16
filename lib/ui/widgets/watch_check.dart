import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Cerchio vuoto ambra: al tap si riempie con la spunta e, dopo una breve
/// animazione, chiama [onChecked] (che di solito fa sparire la riga).
///
/// IMPORTANTE: la riga che lo contiene deve avere una Key legata
/// all'episodio, altrimenti Flutter potrebbe riusare questo stato
/// ("già spuntato") per l'episodio che prende il suo posto in lista.
class WatchCheck extends StatefulWidget {
  const WatchCheck({super.key, required this.onChecked});

  final VoidCallback onChecked;

  @override
  State<WatchCheck> createState() => _WatchCheckState();
}

class _WatchCheckState extends State<WatchCheck> {
  bool _checked = false;

  Future<void> _tap() async {
    if (_checked) return;
    setState(() => _checked = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    widget.onChecked();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Segna come visto',
      child: InkResponse(
        onTap: _tap,
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _checked ? AppColors.accent : Colors.transparent,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: _checked
                ? const Icon(Icons.check, size: 18, color: Colors.black)
                : null,
          ),
        ),
      ),
    );
  }
}
