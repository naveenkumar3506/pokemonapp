import '../entities/pokemon.dart';
import '../../core/error/app_exception.dart';

/// Repository interface for Pokémon data operations
abstract class PokemonRepository {
  /// Fetches a paginated list of Pokémon
  /// 
  /// [offset] - Starting index for pagination
  /// [limit] - Number of items to fetch
  /// 
  /// Returns [PokemonListResult] with the list and pagination info
  /// Throws [AppException] on error
  Future<PokemonListResult> getPokemonList({
    int offset = 0,
    int limit = 20,
  });

  /// Fetches detailed information for a specific Pokémon
  /// 
  /// [id] - Pokémon ID
  /// 
  /// Returns [Pokemon] with full details
  /// Throws [AppException] on error
  Future<Pokemon> getPokemonById(int id);

  /// Refreshes the cache by fetching fresh data from API
  Future<void> refreshCache();
}

