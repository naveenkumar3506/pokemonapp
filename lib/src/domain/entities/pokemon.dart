import 'package:equatable/equatable.dart';

/// Pokémon entity representing a Pokémon in the domain layer
class Pokemon extends Equatable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    this.height,
    this.weight,
    this.stats,
    this.abilities,
    this.cachedImagePath,
    this.isOffline = false,
    this.spriteUrls,
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int? height;
  final int? weight;
  final List<PokemonStat>? stats;
  final List<String>? abilities;
  final String? cachedImagePath;
  final bool isOffline;
  final List<String>? spriteUrls;

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        types,
        height,
        weight,
        stats,
        abilities,
        cachedImagePath,
        isOffline,
        spriteUrls,
      ];
}

/// Pokémon stat entity
class PokemonStat extends Equatable {
  const PokemonStat({
    required this.name,
    required this.value,
  });

  final String name;
  final int value;

  @override
  List<Object?> get props => [name, value];
}

/// Paginated result for Pokémon list
class PokemonListResult extends Equatable {
  const PokemonListResult({
    required this.pokemonList,
    required this.hasNextPage,
    required this.nextOffset,
    this.isOffline = false,
  });

  final List<Pokemon> pokemonList;
  final bool hasNextPage;
  final int nextOffset;
  final bool isOffline;

  @override
  List<Object?> get props => [pokemonList, hasNextPage, nextOffset, isOffline];
}


