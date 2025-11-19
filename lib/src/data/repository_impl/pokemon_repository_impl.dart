import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/app_exception.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../api/models/pokemon_list_response.dart';
import '../api/pokemon_api_client.dart';
import '../db/app_database.dart';
import '../mappers/pokemon_mapper.dart';
import '../image_processing/image_processor.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  PokemonRepositoryImpl({
    required PokemonApiClient apiClient,
    required AppDatabase database,
    required ImageProcessor imageProcessor,
    required Connectivity connectivity,
  })  : _apiClient = apiClient,
        _database = database,
        _imageProcessor = imageProcessor,
        _connectivity = connectivity;


  final PokemonApiClient _apiClient;
  final AppDatabase _database;
  final ImageProcessor _imageProcessor;
  final Connectivity _connectivity;

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // Check if cached data is still valid (24hr limit)
  bool _isCacheFresh(DateTime cachedAt) {
    final diff = DateTime.now().difference(cachedAt);
    return diff.inHours < ApiConstants.cacheFreshnessHours;
  }

  /// Checks if a cached page exists and is fresh
  Future<bool> _shouldUseCachedPage(int offset, int limit) async {
    final hasCachedPage = await _database.hasPokemonRange(offset, limit);
    if (!hasCachedPage) {
      return false;
    }

    final cached = await _database.getPokemonRange(offset, limit);
    return cached.isNotEmpty && _isCacheFresh(cached.first.cachedAt);
  }

  /// Returns cached data with API pagination check
  Future<PokemonListResult> _getCachedWithPaginationCheck({
    required int offset,
    required int limit,
  }) async {
    final cached = await _getPokemonListFromCache(offset: offset, limit: limit);
    
    try {
      final apiCheck = await _apiClient.getPokemonList(offset: offset, limit: limit);
      return PokemonListResult(
        pokemonList: cached.pokemonList,
        hasNextPage: apiCheck.next != null,
        nextOffset: apiCheck.next != null ? offset + limit : offset,
        isOffline: true, // Show offline banner when using cached data
      );
    } catch (_) {
      // API check failed, use cached pagination info
      return cached;
    }
  }

  /// Processes a single Pokémon item with image caching
  Future<Pokemon> _processPokemonWithImage(PokemonListItem item) async {
    final pokemon = PokemonMapper.toEntityFromListItem(item);
    
    try {
      final imagePath = await _imageProcessor.processAndCacheImage(
        imageUrl: pokemon.imageUrl,
        targetSize: ApiConstants.listImageSize,
      );
      return pokemon.copyWith(cachedImagePath: imagePath);
    } catch (_) {
      return pokemon;
    }
  }

  /// Fetches and processes Pokémon list from API
  Future<PokemonListResult> _fetchPokemonListFromApi({
    required int offset,
    required int limit,
  }) async {
    final response = await _apiClient.getPokemonList(
      offset: offset,
      limit: limit,
    );

    final pokemonList = await Future.wait(
      response.results.map(_processPokemonWithImage),
    );

    await _cachePokemonList(pokemonList);

    return PokemonListResult(
      pokemonList: pokemonList,
      hasNextPage: response.next != null,
      nextOffset: response.next != null ? offset + limit : offset,
      isOffline: false,
    );
  }

  /// Attempts to get Pokémon list from cache as fallback
  Future<PokemonListResult?> _tryGetFromCacheFallback({
    required int offset,
    required int limit,
  }) async {
    final hasCachedPage = await _database.hasPokemonRange(offset, limit);
    if (hasCachedPage) {
      return _getPokemonListFromCache(offset: offset, limit: limit);
    }

    final allCached = await _database.getAllPokemon();
    if (allCached.isNotEmpty) {
      return _getPokemonListFromCache(offset: offset, limit: limit);
    }

    return null;
  }

  /// Handles offline mode for getting Pokémon list
  Future<PokemonListResult> _getPokemonListOffline({
    required int offset,
    required int limit,
  }) async {
    final hasCachedPage = await _database.hasPokemonRange(offset, limit);
    if (hasCachedPage) {
      return _getPokemonListFromCache(offset: offset, limit: limit);
    }

    final allCached = await _database.getAllPokemon();
    if (allCached.isNotEmpty) {
      return _getPokemonListFromCache(offset: offset, limit: limit);
    }

    throw CacheException('No cached data for offset=$offset, limit=$limit');
  }

  @override
  Future<PokemonListResult> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    final isOnline = await _isOnline();
    final shouldUseCache = await _shouldUseCachedPage(offset, limit);

    if (isOnline) {
      try {
        if (shouldUseCache) {
          return _getCachedWithPaginationCheck(offset: offset, limit: limit);
        }

        return _fetchPokemonListFromApi(offset: offset, limit: limit);
      } catch (e) {
        final cachedResult = await _tryGetFromCacheFallback(
          offset: offset,
          limit: limit,
        );
        if (cachedResult != null) {
          return cachedResult;
        }
        rethrow;
      }
    } else {
      return _getPokemonListOffline(offset: offset, limit: limit);
    }
  }

  /// Converts database rows to Pokémon entities
  List<Pokemon> _mapTableRowsToEntities(List<PokemonTableData> rows) {
    return rows.map((row) => PokemonMapper.toEntityFromTable(row)).toList();
  }

  /// Creates a result from cached range data
  Future<PokemonListResult> _createResultFromRange({
    required List<PokemonTableData> rangeData,
    required int offset,
    required int limit,
  }) async {
    final pokemonList = _mapTableRowsToEntities(rangeData);
    final total = await _database.getPokemonCount();
    final hasMore = (offset + limit) < total;

    return PokemonListResult(
      pokemonList: pokemonList,
      hasNextPage: hasMore,
      nextOffset: hasMore ? offset + limit : offset,
      isOffline: true, // Always show offline banner when using cached data
    );
  }

  /// Creates a result from all cached data (fallback)
  PokemonListResult _createResultFromAllData({
    required List<PokemonTableData> allData,
    required int offset,
    required int limit,
  }) {
    final pokemonList = _mapTableRowsToEntities(
      allData.skip(offset).take(limit).toList(),
    );
    final hasMore = offset + limit < allData.length;

    return PokemonListResult(
      pokemonList: pokemonList,
      hasNextPage: hasMore,
      nextOffset: hasMore ? offset + limit : offset,
      isOffline: true, // Always show offline banner when using cached data
    );
  }

  Future<PokemonListResult> _getPokemonListFromCache({
    int offset = 0,
    int limit = 20,
  }) async {
    final rangeData = await _database.getPokemonRange(offset, limit);
    
    if (rangeData.isNotEmpty) {
      return _createResultFromRange(
        rangeData: rangeData,
        offset: offset,
        limit: limit,
      );
    }
    
    final allData = await _database.getAllPokemon();
    if (allData.isEmpty) {
      throw CacheException('No cached data available');
    }

    return _createResultFromAllData(
      allData: allData,
      offset: offset,
      limit: limit,
    );
  }

  Future<void> _cachePokemonList(List<Pokemon> pokemonList) async {
    final dbRows = pokemonList.map((p) => PokemonMapper.toTableCompanion(p)).toList();
    await _database.insertOrUpdatePokemonList(dbRows);
  }

  /// Checks if cached Pokémon has complete detail information
  bool _hasCompleteDetailData(Pokemon pokemon) {
    return pokemon.stats != null &&
        pokemon.stats!.isNotEmpty &&
        pokemon.types.isNotEmpty &&
        pokemon.abilities != null &&
        pokemon.abilities!.isNotEmpty;
  }

  /// Processes and caches Pokémon detail with image
  Future<Pokemon> _processAndCachePokemonDetail(Pokemon pokemon) async {
    try {
      final imagePath = await _imageProcessor.processAndCacheImage(
        imageUrl: pokemon.imageUrl,
        targetSize: ApiConstants.detailImageSize,
      );
      final pokemonWithImage = pokemon.copyWith(cachedImagePath: imagePath);
      await _database.insertOrUpdatePokemon(
        PokemonMapper.toTableCompanion(pokemonWithImage),
      );
      return pokemonWithImage;
    } catch (_) {
      // Save without image if processing fails
      await _database.insertOrUpdatePokemon(
        PokemonMapper.toTableCompanion(pokemon),
      );
      return pokemon;
    }
  }

  /// Fetches Pokémon detail from API
  Future<Pokemon> _fetchPokemonDetailFromApi(int id) async {
    final response = await _apiClient.getPokemonById(id);
    final pokemon = PokemonMapper.toEntity(response);
    return _processAndCachePokemonDetail(pokemon);
  }

  /// Gets Pokémon detail when online
  Future<Pokemon> _getPokemonDetailOnline(int id, PokemonTableData? cached) async {
    try {
      return _fetchPokemonDetailFromApi(id);
    } catch (e) {
      if (cached != null) {
        return PokemonMapper.toEntityFromTable(cached);
      }
      rethrow;
    }
  }

  /// Gets Pokémon detail when offline
  Future<Pokemon> _getPokemonDetailOffline(PokemonTableData? cached) {
    if (cached != null) {
      return Future.value(PokemonMapper.toEntityFromTable(cached));
    }
    throw CacheException('Pokémon not found in cache');
  }

  @override
  Future<Pokemon> getPokemonById(int id) async {
    final isOnline = await _isOnline();
    final cached = await _database.getPokemonById(id);
    
    if (cached != null && _isCacheFresh(cached.cachedAt)) {
      final pokemon = PokemonMapper.toEntityFromTable(cached);
      if (_hasCompleteDetailData(pokemon)) {
        return pokemon;
      }
    }

    if (isOnline) {
      return _getPokemonDetailOnline(id, cached);
    } else {
      return _getPokemonDetailOffline(cached);
    }
  }

  @override
  Future<void> refreshCache() async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      throw NetworkException('Cannot refresh cache while offline');
    }

    // Clear old cache
    await _database.clearCache();
    await _imageProcessor.clearCache();

    // Fetch fresh data
    int offset = 0;
    const limit = 20;
    bool hasMore = true;

    while (hasMore) {
      final result = await getPokemonList(offset: offset, limit: limit);
      hasMore = result.hasNextPage;
      offset = result.nextOffset;
    }
  }
}

/// Extension to add copyWith to Pokemon entity
extension PokemonCopyWith on Pokemon {
  Pokemon copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<String>? types,
    int? height,
    int? weight,
    List<PokemonStat>? stats,
    List<String>? abilities,
    String? cachedImagePath,
    bool? isOffline,
    List<String>? spriteUrls,
  }) {
    return Pokemon(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      types: types ?? this.types,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      stats: stats ?? this.stats,
      abilities: abilities ?? this.abilities,
      cachedImagePath: cachedImagePath ?? this.cachedImagePath,
      isOffline: isOffline ?? this.isOffline,
      spriteUrls: spriteUrls ?? this.spriteUrls,
    );
  }
}

