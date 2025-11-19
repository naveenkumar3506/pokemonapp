import 'package:drift/drift.dart';
import 'tables/pokemon_table.dart';

part 'app_database.g.dart';

/// App database using Drift
@DriftDatabase(tables: [PokemonTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Gets all cached Pokémon
  Future<List<PokemonTableData>> getAllPokemon() {
    return (select(pokemonTable)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  /// Gets a Pokémon by ID
  Future<PokemonTableData?> getPokemonById(int id) {
    return (select(pokemonTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts or updates a Pokémon
  Future<void> insertOrUpdatePokemon(PokemonTableCompanion pokemon) {
    return into(pokemonTable).insertOnConflictUpdate(pokemon);
  }

  /// Inserts or updates multiple Pokémon
  Future<void> insertOrUpdatePokemonList(List<PokemonTableCompanion> pokemonList) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(pokemonTable, pokemonList);
    });
  }

  /// Deletes all cached Pokémon
  Future<void> clearCache() {
    return delete(pokemonTable).go();
  }

  /// Gets Pokémon count
  Future<int> getPokemonCount() {
    return (selectOnly(pokemonTable)..addColumns([pokemonTable.id.count()])).getSingle().then((row) => row.read(pokemonTable.id.count()) ?? 0);
  }

  /// Checks if a specific pagination range exists in cache
  /// Returns true if all Pokémon in the range (offset+1 to offset+limit) exist
  Future<bool> hasPokemonRange(int offset, int limit) async {
    final startId = offset + 1; // Pokémon IDs start from 1
    final endId = offset + limit;
    
    final expression = pokemonTable.id.isBiggerOrEqual(Variable(startId)) & 
                       pokemonTable.id.isSmallerOrEqual(Variable(endId));
    
    final count = await (selectOnly(pokemonTable)
          ..addColumns([pokemonTable.id.count()])
          ..where(expression))
        .getSingle()
        .then((row) => row.read(pokemonTable.id.count()) ?? 0);
    
    return count == limit;
  }

  /// Gets Pokémon in a specific range
  Future<List<PokemonTableData>> getPokemonRange(int offset, int limit) async {
    final startId = offset + 1; // Pokémon IDs start from 1
    final endId = offset + limit;
    
    return (select(pokemonTable)
          ..where((t) => 
              t.id.isBiggerOrEqual(Variable(startId)) & 
              t.id.isSmallerOrEqual(Variable(endId)))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }
}

