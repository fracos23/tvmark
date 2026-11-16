import 'package:drift/drift.dart';

import '../domain/enums.dart';

/// Serie seguite. La chiave è l'id di TVmaze, non un autoincrement:
/// così il refresh può fare upsert direttamente sull'id dell'API.
@DataClassName('TvShow')
class TvShows extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get network => text().nullable()();
  TextColumn get status => textEnum<ShowStatus>()();

  /// Timestamp "updated" di TVmaze (secondi epoch): serve a capire,
  /// con /updates/shows, se la serie è cambiata dall'ultimo refresh.
  IntColumn get tvmazeUpdated => integer().nullable()();

  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Episodi delle serie seguite. Anche qui chiave = id TVmaze.
class Episodes extends Table {
  IntColumn get id => integer()();
  IntColumn get showId =>
      integer().references(TvShows, #id, onDelete: KeyAction.cascade)();
  IntColumn get season => integer()();

  /// Nullable: TVmaze ha alcuni speciali senza numero.
  IntColumn get number => integer().nullable()();
  TextColumn get name => text()();

  /// Messa in onda (UTC). Nullable: episodi annunciati senza data.
  DateTimeColumn get airstamp => dateTime().nullable()();
  IntColumn get runtime => integer().nullable()();

  // --- Campi dell'utente: il refresh da TVmaze NON deve mai toccarli ---
  TextColumn get watchStatus => textEnum<WatchStatus>()
      .withDefault(Constant(WatchStatus.toWatch.name))();
  DateTimeColumn get watchedAt => dateTime().nullable()();

  /// Quando l'episodio è comparso per la prima volta nella cache:
  /// servirà per il badge "nuovo".
  DateTimeColumn get firstSeenAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Piccola tabella chiave/valore per dati di servizio
/// (es. data dell'ultimo refresh globale).
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
