import 'package:drift/drift.dart';

/// Table for storing Pokémon list items
class PokemonTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  TextColumn get types => text()(); // JSON array as string
  IntColumn get height => integer().nullable()();
  IntColumn get weight => integer().nullable()();
  TextColumn get stats => text().nullable()(); // JSON array as string
  TextColumn get abilities => text().nullable()(); // JSON array as string
  TextColumn get cachedImagePath => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}


