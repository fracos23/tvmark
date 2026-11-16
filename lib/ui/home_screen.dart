import 'package:flutter/material.dart';

/// Schermata principale. Per ora è un segnaposto: nei prossimi sprint
/// conterrà le sezioni "Usciti", "In arrivo" e "In pausa / senza data".
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TVMark')),
      body: const Center(
        child: Text('Nessuna serie seguita'),
      ),
    );
  }
}
