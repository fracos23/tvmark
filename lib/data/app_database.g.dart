// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TvShowsTable extends TvShows with TableInfo<$TvShowsTable, TvShow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TvShowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _networkMeta = const VerificationMeta(
    'network',
  );
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
    'network',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ShowStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ShowStatus>($TvShowsTable.$converterstatus);
  static const VerificationMeta _tvmazeUpdatedMeta = const VerificationMeta(
    'tvmazeUpdated',
  );
  @override
  late final GeneratedColumn<int> tvmazeUpdated = GeneratedColumn<int>(
    'tvmaze_updated',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    network,
    status,
    tvmazeUpdated,
    lastSyncedAt,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tv_shows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TvShow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('network')) {
      context.handle(
        _networkMeta,
        network.isAcceptableOrUnknown(data['network']!, _networkMeta),
      );
    }
    if (data.containsKey('tvmaze_updated')) {
      context.handle(
        _tvmazeUpdatedMeta,
        tvmazeUpdated.isAcceptableOrUnknown(
          data['tvmaze_updated']!,
          _tvmazeUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TvShow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TvShow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      network: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network'],
      ),
      status: $TvShowsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      tvmazeUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tvmaze_updated'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $TvShowsTable createAlias(String alias) {
    return $TvShowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ShowStatus, String, String> $converterstatus =
      const EnumNameConverter<ShowStatus>(ShowStatus.values);
}

class TvShow extends DataClass implements Insertable<TvShow> {
  final int id;
  final String name;
  final String? imageUrl;
  final String? network;
  final ShowStatus status;

  /// Timestamp "updated" di TVmaze (secondi epoch): serve a capire,
  /// con /updates/shows, se la serie è cambiata dall'ultimo refresh.
  final int? tvmazeUpdated;
  final DateTime? lastSyncedAt;
  final DateTime addedAt;
  const TvShow({
    required this.id,
    required this.name,
    this.imageUrl,
    this.network,
    required this.status,
    this.tvmazeUpdated,
    this.lastSyncedAt,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || network != null) {
      map['network'] = Variable<String>(network);
    }
    {
      map['status'] = Variable<String>(
        $TvShowsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || tvmazeUpdated != null) {
      map['tvmaze_updated'] = Variable<int>(tvmazeUpdated);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  TvShowsCompanion toCompanion(bool nullToAbsent) {
    return TvShowsCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      network: network == null && nullToAbsent
          ? const Value.absent()
          : Value(network),
      status: Value(status),
      tvmazeUpdated: tvmazeUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(tvmazeUpdated),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      addedAt: Value(addedAt),
    );
  }

  factory TvShow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TvShow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      network: serializer.fromJson<String?>(json['network']),
      status: $TvShowsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      tvmazeUpdated: serializer.fromJson<int?>(json['tvmazeUpdated']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'network': serializer.toJson<String?>(network),
      'status': serializer.toJson<String>(
        $TvShowsTable.$converterstatus.toJson(status),
      ),
      'tvmazeUpdated': serializer.toJson<int?>(tvmazeUpdated),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  TvShow copyWith({
    int? id,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> network = const Value.absent(),
    ShowStatus? status,
    Value<int?> tvmazeUpdated = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? addedAt,
  }) => TvShow(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    network: network.present ? network.value : this.network,
    status: status ?? this.status,
    tvmazeUpdated: tvmazeUpdated.present
        ? tvmazeUpdated.value
        : this.tvmazeUpdated,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    addedAt: addedAt ?? this.addedAt,
  );
  TvShow copyWithCompanion(TvShowsCompanion data) {
    return TvShow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      network: data.network.present ? data.network.value : this.network,
      status: data.status.present ? data.status.value : this.status,
      tvmazeUpdated: data.tvmazeUpdated.present
          ? data.tvmazeUpdated.value
          : this.tvmazeUpdated,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TvShow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('network: $network, ')
          ..write('status: $status, ')
          ..write('tvmazeUpdated: $tvmazeUpdated, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    network,
    status,
    tvmazeUpdated,
    lastSyncedAt,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TvShow &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.network == this.network &&
          other.status == this.status &&
          other.tvmazeUpdated == this.tvmazeUpdated &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.addedAt == this.addedAt);
}

class TvShowsCompanion extends UpdateCompanion<TvShow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<String?> network;
  final Value<ShowStatus> status;
  final Value<int?> tvmazeUpdated;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> addedAt;
  const TvShowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.network = const Value.absent(),
    this.status = const Value.absent(),
    this.tvmazeUpdated = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  TvShowsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    this.network = const Value.absent(),
    required ShowStatus status,
    this.tvmazeUpdated = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : name = Value(name),
       status = Value(status);
  static Insertable<TvShow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? network,
    Expression<String>? status,
    Expression<int>? tvmazeUpdated,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (network != null) 'network': network,
      if (status != null) 'status': status,
      if (tvmazeUpdated != null) 'tvmaze_updated': tvmazeUpdated,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  TvShowsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<String?>? network,
    Value<ShowStatus>? status,
    Value<int?>? tvmazeUpdated,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? addedAt,
  }) {
    return TvShowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      network: network ?? this.network,
      status: status ?? this.status,
      tvmazeUpdated: tvmazeUpdated ?? this.tvmazeUpdated,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TvShowsTable.$converterstatus.toSql(status.value),
      );
    }
    if (tvmazeUpdated.present) {
      map['tvmaze_updated'] = Variable<int>(tvmazeUpdated.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TvShowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('network: $network, ')
          ..write('status: $status, ')
          ..write('tvmazeUpdated: $tvmazeUpdated, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showIdMeta = const VerificationMeta('showId');
  @override
  late final GeneratedColumn<int> showId = GeneratedColumn<int>(
    'show_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tv_shows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _airstampMeta = const VerificationMeta(
    'airstamp',
  );
  @override
  late final GeneratedColumn<DateTime> airstamp = GeneratedColumn<DateTime>(
    'airstamp',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runtimeMeta = const VerificationMeta(
    'runtime',
  );
  @override
  late final GeneratedColumn<int> runtime = GeneratedColumn<int>(
    'runtime',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WatchStatus, String> watchStatus =
      GeneratedColumn<String>(
        'watch_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(WatchStatus.toWatch.name),
      ).withConverter<WatchStatus>($EpisodesTable.$converterwatchStatus);
  static const VerificationMeta _watchedAtMeta = const VerificationMeta(
    'watchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> watchedAt = GeneratedColumn<DateTime>(
    'watched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    showId,
    season,
    number,
    name,
    airstamp,
    runtime,
    watchStatus,
    watchedAt,
    firstSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('show_id')) {
      context.handle(
        _showIdMeta,
        showId.isAcceptableOrUnknown(data['show_id']!, _showIdMeta),
      );
    } else if (isInserting) {
      context.missing(_showIdMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('airstamp')) {
      context.handle(
        _airstampMeta,
        airstamp.isAcceptableOrUnknown(data['airstamp']!, _airstampMeta),
      );
    }
    if (data.containsKey('runtime')) {
      context.handle(
        _runtimeMeta,
        runtime.isAcceptableOrUnknown(data['runtime']!, _runtimeMeta),
      );
    }
    if (data.containsKey('watched_at')) {
      context.handle(
        _watchedAtMeta,
        watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      showId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}show_id'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      airstamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}airstamp'],
      ),
      runtime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runtime'],
      ),
      watchStatus: $EpisodesTable.$converterwatchStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}watch_status'],
        )!,
      ),
      watchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watched_at'],
      ),
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WatchStatus, String, String> $converterwatchStatus =
      const EnumNameConverter<WatchStatus>(WatchStatus.values);
}

class Episode extends DataClass implements Insertable<Episode> {
  final int id;
  final int showId;
  final int season;

  /// Nullable: TVmaze ha alcuni speciali senza numero.
  final int? number;
  final String name;

  /// Messa in onda (UTC). Nullable: episodi annunciati senza data.
  final DateTime? airstamp;
  final int? runtime;
  final WatchStatus watchStatus;
  final DateTime? watchedAt;

  /// Quando l'episodio è comparso per la prima volta nella cache:
  /// servirà per il badge "nuovo".
  final DateTime firstSeenAt;
  const Episode({
    required this.id,
    required this.showId,
    required this.season,
    this.number,
    required this.name,
    this.airstamp,
    this.runtime,
    required this.watchStatus,
    this.watchedAt,
    required this.firstSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['show_id'] = Variable<int>(showId);
    map['season'] = Variable<int>(season);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || airstamp != null) {
      map['airstamp'] = Variable<DateTime>(airstamp);
    }
    if (!nullToAbsent || runtime != null) {
      map['runtime'] = Variable<int>(runtime);
    }
    {
      map['watch_status'] = Variable<String>(
        $EpisodesTable.$converterwatchStatus.toSql(watchStatus),
      );
    }
    if (!nullToAbsent || watchedAt != null) {
      map['watched_at'] = Variable<DateTime>(watchedAt);
    }
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      showId: Value(showId),
      season: Value(season),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      name: Value(name),
      airstamp: airstamp == null && nullToAbsent
          ? const Value.absent()
          : Value(airstamp),
      runtime: runtime == null && nullToAbsent
          ? const Value.absent()
          : Value(runtime),
      watchStatus: Value(watchStatus),
      watchedAt: watchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(watchedAt),
      firstSeenAt: Value(firstSeenAt),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<int>(json['id']),
      showId: serializer.fromJson<int>(json['showId']),
      season: serializer.fromJson<int>(json['season']),
      number: serializer.fromJson<int?>(json['number']),
      name: serializer.fromJson<String>(json['name']),
      airstamp: serializer.fromJson<DateTime?>(json['airstamp']),
      runtime: serializer.fromJson<int?>(json['runtime']),
      watchStatus: $EpisodesTable.$converterwatchStatus.fromJson(
        serializer.fromJson<String>(json['watchStatus']),
      ),
      watchedAt: serializer.fromJson<DateTime?>(json['watchedAt']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'showId': serializer.toJson<int>(showId),
      'season': serializer.toJson<int>(season),
      'number': serializer.toJson<int?>(number),
      'name': serializer.toJson<String>(name),
      'airstamp': serializer.toJson<DateTime?>(airstamp),
      'runtime': serializer.toJson<int?>(runtime),
      'watchStatus': serializer.toJson<String>(
        $EpisodesTable.$converterwatchStatus.toJson(watchStatus),
      ),
      'watchedAt': serializer.toJson<DateTime?>(watchedAt),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
    };
  }

  Episode copyWith({
    int? id,
    int? showId,
    int? season,
    Value<int?> number = const Value.absent(),
    String? name,
    Value<DateTime?> airstamp = const Value.absent(),
    Value<int?> runtime = const Value.absent(),
    WatchStatus? watchStatus,
    Value<DateTime?> watchedAt = const Value.absent(),
    DateTime? firstSeenAt,
  }) => Episode(
    id: id ?? this.id,
    showId: showId ?? this.showId,
    season: season ?? this.season,
    number: number.present ? number.value : this.number,
    name: name ?? this.name,
    airstamp: airstamp.present ? airstamp.value : this.airstamp,
    runtime: runtime.present ? runtime.value : this.runtime,
    watchStatus: watchStatus ?? this.watchStatus,
    watchedAt: watchedAt.present ? watchedAt.value : this.watchedAt,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      showId: data.showId.present ? data.showId.value : this.showId,
      season: data.season.present ? data.season.value : this.season,
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
      airstamp: data.airstamp.present ? data.airstamp.value : this.airstamp,
      runtime: data.runtime.present ? data.runtime.value : this.runtime,
      watchStatus: data.watchStatus.present
          ? data.watchStatus.value
          : this.watchStatus,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('showId: $showId, ')
          ..write('season: $season, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('airstamp: $airstamp, ')
          ..write('runtime: $runtime, ')
          ..write('watchStatus: $watchStatus, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('firstSeenAt: $firstSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    showId,
    season,
    number,
    name,
    airstamp,
    runtime,
    watchStatus,
    watchedAt,
    firstSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.showId == this.showId &&
          other.season == this.season &&
          other.number == this.number &&
          other.name == this.name &&
          other.airstamp == this.airstamp &&
          other.runtime == this.runtime &&
          other.watchStatus == this.watchStatus &&
          other.watchedAt == this.watchedAt &&
          other.firstSeenAt == this.firstSeenAt);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<int> id;
  final Value<int> showId;
  final Value<int> season;
  final Value<int?> number;
  final Value<String> name;
  final Value<DateTime?> airstamp;
  final Value<int?> runtime;
  final Value<WatchStatus> watchStatus;
  final Value<DateTime?> watchedAt;
  final Value<DateTime> firstSeenAt;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.showId = const Value.absent(),
    this.season = const Value.absent(),
    this.number = const Value.absent(),
    this.name = const Value.absent(),
    this.airstamp = const Value.absent(),
    this.runtime = const Value.absent(),
    this.watchStatus = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
  });
  EpisodesCompanion.insert({
    this.id = const Value.absent(),
    required int showId,
    required int season,
    this.number = const Value.absent(),
    required String name,
    this.airstamp = const Value.absent(),
    this.runtime = const Value.absent(),
    this.watchStatus = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
  }) : showId = Value(showId),
       season = Value(season),
       name = Value(name);
  static Insertable<Episode> custom({
    Expression<int>? id,
    Expression<int>? showId,
    Expression<int>? season,
    Expression<int>? number,
    Expression<String>? name,
    Expression<DateTime>? airstamp,
    Expression<int>? runtime,
    Expression<String>? watchStatus,
    Expression<DateTime>? watchedAt,
    Expression<DateTime>? firstSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (showId != null) 'show_id': showId,
      if (season != null) 'season': season,
      if (number != null) 'number': number,
      if (name != null) 'name': name,
      if (airstamp != null) 'airstamp': airstamp,
      if (runtime != null) 'runtime': runtime,
      if (watchStatus != null) 'watch_status': watchStatus,
      if (watchedAt != null) 'watched_at': watchedAt,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
    });
  }

  EpisodesCompanion copyWith({
    Value<int>? id,
    Value<int>? showId,
    Value<int>? season,
    Value<int?>? number,
    Value<String>? name,
    Value<DateTime?>? airstamp,
    Value<int?>? runtime,
    Value<WatchStatus>? watchStatus,
    Value<DateTime?>? watchedAt,
    Value<DateTime>? firstSeenAt,
  }) {
    return EpisodesCompanion(
      id: id ?? this.id,
      showId: showId ?? this.showId,
      season: season ?? this.season,
      number: number ?? this.number,
      name: name ?? this.name,
      airstamp: airstamp ?? this.airstamp,
      runtime: runtime ?? this.runtime,
      watchStatus: watchStatus ?? this.watchStatus,
      watchedAt: watchedAt ?? this.watchedAt,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (showId.present) {
      map['show_id'] = Variable<int>(showId.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (airstamp.present) {
      map['airstamp'] = Variable<DateTime>(airstamp.value);
    }
    if (runtime.present) {
      map['runtime'] = Variable<int>(runtime.value);
    }
    if (watchStatus.present) {
      map['watch_status'] = Variable<String>(
        $EpisodesTable.$converterwatchStatus.toSql(watchStatus.value),
      );
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<DateTime>(watchedAt.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('showId: $showId, ')
          ..write('season: $season, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('airstamp: $airstamp, ')
          ..write('runtime: $runtime, ')
          ..write('watchStatus: $watchStatus, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('firstSeenAt: $firstSeenAt')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TvShowsTable tvShows = $TvShowsTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tvShows,
    episodes,
    appMeta,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tv_shows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('episodes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TvShowsTableCreateCompanionBuilder = TvShowsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> imageUrl,
  Value<String?> network,
  required ShowStatus status,
  Value<int?> tvmazeUpdated,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime> addedAt,
});
typedef $$TvShowsTableUpdateCompanionBuilder = TvShowsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> imageUrl,
  Value<String?> network,
  Value<ShowStatus> status,
  Value<int?> tvmazeUpdated,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime> addedAt,
});

final class $$TvShowsTableReferences
    extends BaseReferences<_$AppDatabase, $TvShowsTable, TvShow> {
  $$TvShowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EpisodesTable, List<Episode>> _episodesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.episodes,
    aliasName: 'tv_shows__id__episodes__show_id',
  );

  $$EpisodesTableProcessedTableManager get episodesRefs {
    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.showId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TvShowsTableFilterComposer
    extends Composer<_$AppDatabase, $TvShowsTable> {
  $$TvShowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ShowStatus, ShowStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get tvmazeUpdated => $composableBuilder(
    column: $table.tvmazeUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> episodesRefs(
    Expression<bool> Function($$EpisodesTableFilterComposer f) f,
  ) {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.showId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TvShowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TvShowsTable> {
  $$TvShowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tvmazeUpdated => $composableBuilder(
    column: $table.tvmazeUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TvShowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TvShowsTable> {
  $$TvShowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ShowStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get tvmazeUpdated => $composableBuilder(
    column: $table.tvmazeUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  Expression<T> episodesRefs<T extends Object>(
    Expression<T> Function($$EpisodesTableAnnotationComposer a) f,
  ) {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.showId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TvShowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TvShowsTable,
          TvShow,
          $$TvShowsTableFilterComposer,
          $$TvShowsTableOrderingComposer,
          $$TvShowsTableAnnotationComposer,
          $$TvShowsTableCreateCompanionBuilder,
          $$TvShowsTableUpdateCompanionBuilder,
          (TvShow, $$TvShowsTableReferences),
          TvShow,
          PrefetchHooks Function({bool episodesRefs})
        > {
  $$TvShowsTableTableManager(_$AppDatabase db, $TvShowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TvShowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TvShowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TvShowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> network = const Value.absent(),
                Value<ShowStatus> status = const Value.absent(),
                Value<int?> tvmazeUpdated = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => TvShowsCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                network: network,
                status: status,
                tvmazeUpdated: tvmazeUpdated,
                lastSyncedAt: lastSyncedAt,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> network = const Value.absent(),
                required ShowStatus status,
                Value<int?> tvmazeUpdated = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => TvShowsCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                network: network,
                status: status,
                tvmazeUpdated: tvmazeUpdated,
                lastSyncedAt: lastSyncedAt,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TvShowsTable, TvShow>(table),
                  $$TvShowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (episodesRefs) db.episodes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (episodesRefs)
                    await $_getPrefetchedDataByColumns<
                      TvShow,
                      $TvShowsTable,
                      Episode,
                      $EpisodesTable
                    >(
                      currentTable: table,
                      referencedTable: $$TvShowsTableReferences
                          ._episodesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TvShowsTableReferences(db, table, p0).episodesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'show_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TvShowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TvShowsTable,
      TvShow,
      $$TvShowsTableFilterComposer,
      $$TvShowsTableOrderingComposer,
      $$TvShowsTableAnnotationComposer,
      $$TvShowsTableCreateCompanionBuilder,
      $$TvShowsTableUpdateCompanionBuilder,
      (TvShow, $$TvShowsTableReferences),
      TvShow,
      PrefetchHooks Function({bool episodesRefs})
    >;
typedef $$EpisodesTableCreateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  required int showId,
  required int season,
  Value<int?> number,
  required String name,
  Value<DateTime?> airstamp,
  Value<int?> runtime,
  Value<WatchStatus> watchStatus,
  Value<DateTime?> watchedAt,
  Value<DateTime> firstSeenAt,
});
typedef $$EpisodesTableUpdateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  Value<int> showId,
  Value<int> season,
  Value<int?> number,
  Value<String> name,
  Value<DateTime?> airstamp,
  Value<int?> runtime,
  Value<WatchStatus> watchStatus,
  Value<DateTime?> watchedAt,
  Value<DateTime> firstSeenAt,
});

final class $$EpisodesTableReferences
    extends BaseReferences<_$AppDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TvShowsTable _showIdTable(_$AppDatabase db) =>
      db.tvShows.createAlias('episodes__show_id__tv_shows__id');

  $$TvShowsTableProcessedTableManager get showId {
    final $_column = $_itemColumn<int>('show_id')!;

    final manager = $$TvShowsTableTableManager(
      $_db,
      $_db.tvShows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_showIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get airstamp => $composableBuilder(
    column: $table.airstamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runtime => $composableBuilder(
    column: $table.runtime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WatchStatus, WatchStatus, String>
  get watchStatus => $composableBuilder(
    column: $table.watchStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TvShowsTableFilterComposer get showId {
    final $$TvShowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.showId,
      referencedTable: $db.tvShows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TvShowsTableFilterComposer(
            $db: $db,
            $table: $db.tvShows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get airstamp => $composableBuilder(
    column: $table.airstamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runtime => $composableBuilder(
    column: $table.runtime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watchStatus => $composableBuilder(
    column: $table.watchStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TvShowsTableOrderingComposer get showId {
    final $$TvShowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.showId,
      referencedTable: $db.tvShows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TvShowsTableOrderingComposer(
            $db: $db,
            $table: $db.tvShows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get airstamp =>
      $composableBuilder(column: $table.airstamp, builder: (column) => column);

  GeneratedColumn<int> get runtime =>
      $composableBuilder(column: $table.runtime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WatchStatus, String> get watchStatus =>
      $composableBuilder(
        column: $table.watchStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  $$TvShowsTableAnnotationComposer get showId {
    final $$TvShowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.showId,
      referencedTable: $db.tvShows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TvShowsTableAnnotationComposer(
            $db: $db,
            $table: $db.tvShows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, $$EpisodesTableReferences),
          Episode,
          PrefetchHooks Function({bool showId})
        > {
  $$EpisodesTableTableManager(_$AppDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> showId = const Value.absent(),
                Value<int> season = const Value.absent(),
                Value<int?> number = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> airstamp = const Value.absent(),
                Value<int?> runtime = const Value.absent(),
                Value<WatchStatus> watchStatus = const Value.absent(),
                Value<DateTime?> watchedAt = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
              }) => EpisodesCompanion(
                id: id,
                showId: showId,
                season: season,
                number: number,
                name: name,
                airstamp: airstamp,
                runtime: runtime,
                watchStatus: watchStatus,
                watchedAt: watchedAt,
                firstSeenAt: firstSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int showId,
                required int season,
                Value<int?> number = const Value.absent(),
                required String name,
                Value<DateTime?> airstamp = const Value.absent(),
                Value<int?> runtime = const Value.absent(),
                Value<WatchStatus> watchStatus = const Value.absent(),
                Value<DateTime?> watchedAt = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
              }) => EpisodesCompanion.insert(
                id: id,
                showId: showId,
                season: season,
                number: number,
                name: name,
                airstamp: airstamp,
                runtime: runtime,
                watchStatus: watchStatus,
                watchedAt: watchedAt,
                firstSeenAt: firstSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpisodesTable, Episode>(table),
                  $$EpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({showId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (showId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.showId,
                        referencedTable: $$EpisodesTableReferences._showIdTable(
                          db,
                        ),
                        referencedColumn: $$EpisodesTableReferences
                            ._showIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, $$EpisodesTableReferences),
      Episode,
      PrefetchHooks Function({bool showId})
    >;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaData>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TvShowsTableTableManager get tvShows =>
      $$TvShowsTableTableManager(_db, _db.tvShows);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
