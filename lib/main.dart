import 'package:material_ui/material_ui.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_database.dart';
import 'data/show_repository.dart';
import 'data/tvmaze_client.dart';
import 'ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carica nomi di giorni e mesi in italiano per DateFormat.
  await initializeDateFormatting('it_IT');

  final repository = ShowRepository(db: AppDatabase(), api: TvmazeClient());
  runApp(TvMarkApp(repository: repository));
}

class TvMarkApp extends StatelessWidget {
  const TvMarkApp({super.key, required this.repository});

  final ShowRepository repository;

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
      home: HomeScreen(repository: repository),
    );
  }
}
