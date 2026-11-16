import 'package:flutter/material.dart';

import 'ui/home_screen.dart';

void main() {
  runApp(const TvMarkApp());
}

class TvMarkApp extends StatelessWidget {
  const TvMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TVMark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
