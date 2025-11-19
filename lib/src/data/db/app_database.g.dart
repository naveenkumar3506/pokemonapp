// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PokemonTableTable extends PokemonTable
    with TableInfo<$PokemonTableTable, PokemonTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typesMeta = const VerificationMeta('types');
  @override
  late final GeneratedColumn<String> types = GeneratedColumn<String>(
      'types', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
      'weight', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsMeta = const VerificationMeta('stats');
  @override
  late final GeneratedColumn<String> stats = GeneratedColumn<String>(
      'stats', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _abilitiesMeta =
      const VerificationMeta('abilities');
  @override
  late final GeneratedColumn<String> abilities = GeneratedColumn<String>(
      'abilities', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedImagePathMeta =
      const VerificationMeta('cachedImagePath');
  @override
  late final GeneratedColumn<String> cachedImagePath = GeneratedColumn<String>(
      'cached_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        imageUrl,
        types,
        height,
        weight,
        stats,
        abilities,
        cachedImagePath,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_table';
  @override
  VerificationContext validateIntegrity(Insertable<PokemonTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('types')) {
      context.handle(
          _typesMeta, types.isAcceptableOrUnknown(data['types']!, _typesMeta));
    } else if (isInserting) {
      context.missing(_typesMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('stats')) {
      context.handle(
          _statsMeta, stats.isAcceptableOrUnknown(data['stats']!, _statsMeta));
    }
    if (data.containsKey('abilities')) {
      context.handle(_abilitiesMeta,
          abilities.isAcceptableOrUnknown(data['abilities']!, _abilitiesMeta));
    }
    if (data.containsKey('cached_image_path')) {
      context.handle(
          _cachedImagePathMeta,
          cachedImagePath.isAcceptableOrUnknown(
              data['cached_image_path']!, _cachedImagePathMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      types: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}types'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight']),
      stats: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stats']),
      abilities: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}abilities']),
      cachedImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cached_image_path']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $PokemonTableTable createAlias(String alias) {
    return $PokemonTableTable(attachedDatabase, alias);
  }
}

class PokemonTableData extends DataClass
    implements Insertable<PokemonTableData> {
  final int id;
  final String name;
  final String imageUrl;
  final String types;
  final int? height;
  final int? weight;
  final String? stats;
  final String? abilities;
  final String? cachedImagePath;
  final DateTime cachedAt;
  const PokemonTableData(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.types,
      this.height,
      this.weight,
      this.stats,
      this.abilities,
      this.cachedImagePath,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['image_url'] = Variable<String>(imageUrl);
    map['types'] = Variable<String>(types);
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<int>(weight);
    }
    if (!nullToAbsent || stats != null) {
      map['stats'] = Variable<String>(stats);
    }
    if (!nullToAbsent || abilities != null) {
      map['abilities'] = Variable<String>(abilities);
    }
    if (!nullToAbsent || cachedImagePath != null) {
      map['cached_image_path'] = Variable<String>(cachedImagePath);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  PokemonTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonTableCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: Value(imageUrl),
      types: Value(types),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      stats:
          stats == null && nullToAbsent ? const Value.absent() : Value(stats),
      abilities: abilities == null && nullToAbsent
          ? const Value.absent()
          : Value(abilities),
      cachedImagePath: cachedImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedImagePath),
      cachedAt: Value(cachedAt),
    );
  }

  factory PokemonTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      types: serializer.fromJson<String>(json['types']),
      height: serializer.fromJson<int?>(json['height']),
      weight: serializer.fromJson<int?>(json['weight']),
      stats: serializer.fromJson<String?>(json['stats']),
      abilities: serializer.fromJson<String?>(json['abilities']),
      cachedImagePath: serializer.fromJson<String?>(json['cachedImagePath']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'types': serializer.toJson<String>(types),
      'height': serializer.toJson<int?>(height),
      'weight': serializer.toJson<int?>(weight),
      'stats': serializer.toJson<String?>(stats),
      'abilities': serializer.toJson<String?>(abilities),
      'cachedImagePath': serializer.toJson<String?>(cachedImagePath),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  PokemonTableData copyWith(
          {int? id,
          String? name,
          String? imageUrl,
          String? types,
          Value<int?> height = const Value.absent(),
          Value<int?> weight = const Value.absent(),
          Value<String?> stats = const Value.absent(),
          Value<String?> abilities = const Value.absent(),
          Value<String?> cachedImagePath = const Value.absent(),
          DateTime? cachedAt}) =>
      PokemonTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        types: types ?? this.types,
        height: height.present ? height.value : this.height,
        weight: weight.present ? weight.value : this.weight,
        stats: stats.present ? stats.value : this.stats,
        abilities: abilities.present ? abilities.value : this.abilities,
        cachedImagePath: cachedImagePath.present
            ? cachedImagePath.value
            : this.cachedImagePath,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  PokemonTableData copyWithCompanion(PokemonTableCompanion data) {
    return PokemonTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      types: data.types.present ? data.types.value : this.types,
      height: data.height.present ? data.height.value : this.height,
      weight: data.weight.present ? data.weight.value : this.weight,
      stats: data.stats.present ? data.stats.value : this.stats,
      abilities: data.abilities.present ? data.abilities.value : this.abilities,
      cachedImagePath: data.cachedImagePath.present
          ? data.cachedImagePath.value
          : this.cachedImagePath,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('types: $types, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('stats: $stats, ')
          ..write('abilities: $abilities, ')
          ..write('cachedImagePath: $cachedImagePath, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, imageUrl, types, height, weight,
      stats, abilities, cachedImagePath, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.types == this.types &&
          other.height == this.height &&
          other.weight == this.weight &&
          other.stats == this.stats &&
          other.abilities == this.abilities &&
          other.cachedImagePath == this.cachedImagePath &&
          other.cachedAt == this.cachedAt);
}

class PokemonTableCompanion extends UpdateCompanion<PokemonTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> imageUrl;
  final Value<String> types;
  final Value<int?> height;
  final Value<int?> weight;
  final Value<String?> stats;
  final Value<String?> abilities;
  final Value<String?> cachedImagePath;
  final Value<DateTime> cachedAt;
  const PokemonTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.types = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.stats = const Value.absent(),
    this.abilities = const Value.absent(),
    this.cachedImagePath = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  PokemonTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String imageUrl,
    required String types,
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.stats = const Value.absent(),
    this.abilities = const Value.absent(),
    this.cachedImagePath = const Value.absent(),
    required DateTime cachedAt,
  })  : name = Value(name),
        imageUrl = Value(imageUrl),
        types = Value(types),
        cachedAt = Value(cachedAt);
  static Insertable<PokemonTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? types,
    Expression<int>? height,
    Expression<int>? weight,
    Expression<String>? stats,
    Expression<String>? abilities,
    Expression<String>? cachedImagePath,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (types != null) 'types': types,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (stats != null) 'stats': stats,
      if (abilities != null) 'abilities': abilities,
      if (cachedImagePath != null) 'cached_image_path': cachedImagePath,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  PokemonTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? imageUrl,
      Value<String>? types,
      Value<int?>? height,
      Value<int?>? weight,
      Value<String?>? stats,
      Value<String?>? abilities,
      Value<String?>? cachedImagePath,
      Value<DateTime>? cachedAt}) {
    return PokemonTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      stats: stats ?? this.stats,
      abilities: abilities ?? this.abilities,
      cachedImagePath: cachedImagePath ?? this.cachedImagePath,
      cachedAt: cachedAt ?? this.cachedAt,
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
    if (types.present) {
      map['types'] = Variable<String>(types.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (stats.present) {
      map['stats'] = Variable<String>(stats.value);
    }
    if (abilities.present) {
      map['abilities'] = Variable<String>(abilities.value);
    }
    if (cachedImagePath.present) {
      map['cached_image_path'] = Variable<String>(cachedImagePath.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('types: $types, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('stats: $stats, ')
          ..write('abilities: $abilities, ')
          ..write('cachedImagePath: $cachedImagePath, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabase.connect(DatabaseConnection c) : super.connect(c);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonTableTable pokemonTable = $PokemonTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pokemonTable];
}

typedef $$PokemonTableTableCreateCompanionBuilder = PokemonTableCompanion
    Function({
  Value<int> id,
  required String name,
  required String imageUrl,
  required String types,
  Value<int?> height,
  Value<int?> weight,
  Value<String?> stats,
  Value<String?> abilities,
  Value<String?> cachedImagePath,
  required DateTime cachedAt,
});
typedef $$PokemonTableTableUpdateCompanionBuilder = PokemonTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> imageUrl,
  Value<String> types,
  Value<int?> height,
  Value<int?> weight,
  Value<String?> stats,
  Value<String?> abilities,
  Value<String?> cachedImagePath,
  Value<DateTime> cachedAt,
});

class $$PokemonTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get types => $composableBuilder(
      column: $table.types, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stats => $composableBuilder(
      column: $table.stats, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get abilities => $composableBuilder(
      column: $table.abilities, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cachedImagePath => $composableBuilder(
      column: $table.cachedImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$PokemonTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get types => $composableBuilder(
      column: $table.types, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stats => $composableBuilder(
      column: $table.stats, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get abilities => $composableBuilder(
      column: $table.abilities, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cachedImagePath => $composableBuilder(
      column: $table.cachedImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$PokemonTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableAnnotationComposer({
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

  GeneratedColumn<String> get types =>
      $composableBuilder(column: $table.types, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get stats =>
      $composableBuilder(column: $table.stats, builder: (column) => column);

  GeneratedColumn<String> get abilities =>
      $composableBuilder(column: $table.abilities, builder: (column) => column);

  GeneratedColumn<String> get cachedImagePath => $composableBuilder(
      column: $table.cachedImagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$PokemonTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PokemonTableTable,
    PokemonTableData,
    $$PokemonTableTableFilterComposer,
    $$PokemonTableTableOrderingComposer,
    $$PokemonTableTableAnnotationComposer,
    $$PokemonTableTableCreateCompanionBuilder,
    $$PokemonTableTableUpdateCompanionBuilder,
    (
      PokemonTableData,
      BaseReferences<_$AppDatabase, $PokemonTableTable, PokemonTableData>
    ),
    PokemonTableData,
    PrefetchHooks Function()> {
  $$PokemonTableTableTableManager(_$AppDatabase db, $PokemonTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> types = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<int?> weight = const Value.absent(),
            Value<String?> stats = const Value.absent(),
            Value<String?> abilities = const Value.absent(),
            Value<String?> cachedImagePath = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              PokemonTableCompanion(
            id: id,
            name: name,
            imageUrl: imageUrl,
            types: types,
            height: height,
            weight: weight,
            stats: stats,
            abilities: abilities,
            cachedImagePath: cachedImagePath,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String imageUrl,
            required String types,
            Value<int?> height = const Value.absent(),
            Value<int?> weight = const Value.absent(),
            Value<String?> stats = const Value.absent(),
            Value<String?> abilities = const Value.absent(),
            Value<String?> cachedImagePath = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              PokemonTableCompanion.insert(
            id: id,
            name: name,
            imageUrl: imageUrl,
            types: types,
            height: height,
            weight: weight,
            stats: stats,
            abilities: abilities,
            cachedImagePath: cachedImagePath,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PokemonTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PokemonTableTable,
    PokemonTableData,
    $$PokemonTableTableFilterComposer,
    $$PokemonTableTableOrderingComposer,
    $$PokemonTableTableAnnotationComposer,
    $$PokemonTableTableCreateCompanionBuilder,
    $$PokemonTableTableUpdateCompanionBuilder,
    (
      PokemonTableData,
      BaseReferences<_$AppDatabase, $PokemonTableTable, PokemonTableData>
    ),
    PokemonTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonTableTableTableManager get pokemonTable =>
      $$PokemonTableTableTableManager(_db, _db.pokemonTable);
}
