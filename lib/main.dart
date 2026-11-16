import 'package:material_ui/material_ui.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_database.dart';
import 'data/show_repository.dart';
import 'data/tmdb_client.dart';
import 'data/tvmaze_client.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carica nomi di giorni e mesi in italiano per DateFormat.
  await initializeDateFormatting('it_IT');

  // Chiave TMDB passata all'avvio con --dart-define-from-file=secrets.json
  // (file escluso da git). Se manca, TMDB resta disattivato.
  const tmdbKey = String.fromEnvironment('TMDB_KEY');

  final repository = ShowRepository(
    db: AppDatabase(),
    api: TvmazeClient(),
    tmdb: TmdbClient(credential: tmdbKey),
  );
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
      theme: buildAppTheme(),
      home: HomeScreen(repository: repository),
    );
  }
}
