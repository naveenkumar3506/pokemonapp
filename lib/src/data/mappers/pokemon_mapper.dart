import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/pokemon.dart';
import '../api/models/pokemon_detail_response.dart';
import '../api/models/pokemon_list_response.dart';
import '../db/app_database.dart';

/// Mapper for converting API models to domain entities
class PokemonMapper {
  PokemonMapper._();

  /// Converts API detail response to domain entity
  static Pokemon toEntity(PokemonDetailResponse response, {String? cachedImagePath, bool isOffline = false}) {
    return Pokemon(
      id: response.id,
      name: response.name,
      imageUrl: response.sprites.bestImageUrl ?? '',
      types: response.types.map((t) => t.type.name).toList(),
      height: response.height,
      weight: response.weight,
      stats: response.stats
          .map((s) => PokemonStat(name: s.stat.name, value: s.baseStat))
          .toList(),
      abilities: response.abilities.map((a) => a.ability.name).toList(),
      cachedImagePath: cachedImagePath,
      isOffline: isOffline,
      spriteUrls: response.sprites.allSpriteUrls,
    );
  }

  /// Converts list item to domain entity (minimal info)
  static Pokemon toEntityFromListItem(PokemonListItem item, {String? cachedImagePath, bool isOffline = false}) {
    return Pokemon(
      id: item.id,
      name: item.name,
      imageUrl: ApiConstants.getPokemonImageUrl(item.id),
      types: [], // Will be populated when detail is fetched
      cachedImagePath: cachedImagePath,
      isOffline: isOffline,
    );
  }

  /// Converts database table data to domain entity
  static Pokemon toEntityFromTable(PokemonTableData table) {
    return Pokemon(
      id: table.id,
      name: table.name,
      imageUrl: table.imageUrl,
      types: _parseJsonList(table.types),
      height: table.height,
      weight: table.weight,
      stats: table.stats != null
          ? _parseStats(table.stats!)
          : null,
      abilities: table.abilities != null
          ? _parseJsonList(table.abilities!)
          : null,
      cachedImagePath: table.cachedImagePath,
      isOffline: true, // Cached data is always offline
    );
  }

  /// Converts domain entity to table companion for database
  static PokemonTableCompanion toTableCompanion(Pokemon pokemon) {
    return PokemonTableCompanion(
      id: Value(pokemon.id),
      name: Value(pokemon.name),
      imageUrl: Value(pokemon.imageUrl),
      types: Value(_encodeJsonList(pokemon.types)),
      height: Value.absentIfNull(pokemon.height),
      weight: Value.absentIfNull(pokemon.weight),
      stats: Value.absentIfNull(pokemon.stats != null ? _encodeStats(pokemon.stats!) : null),
      abilities: Value.absentIfNull(pokemon.abilities != null ? _encodeJsonList(pokemon.abilities!) : null),
      cachedImagePath: Value.absentIfNull(pokemon.cachedImagePath),
      cachedAt: Value(DateTime.now()),
    );
  }

  static List<String> _parseJsonList(String json) {
    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  static String _encodeJsonList(List<String> list) {
    return jsonEncode(list);
  }

  static List<PokemonStat> _parseStats(String json) {
    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded
          .map((e) {
            final map = e as Map<String, dynamic>;
            return PokemonStat(
              name: map['name'] as String,
              value: map['value'] as int,
            );
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  static String _encodeStats(List<PokemonStat> stats) {
    final list = stats.map((s) => {'name': s.name, 'value': s.value}).toList();
    return jsonEncode(list);
  }
}

