import 'package:equatable/equatable.dart';
import '../../../domain/entities/pokemon.dart';

abstract class PokemonListState extends Equatable {
  const PokemonListState();

  @override
  List<Object?> get props => [];
}

class PokemonListInitial extends PokemonListState {
  const PokemonListInitial();
}

class PokemonListLoading extends PokemonListState {
  const PokemonListLoading();
}

/// Loaded state with Pokémon list
class PokemonListLoaded extends PokemonListState {
  const PokemonListLoaded({
    required this.pokemonList,
    required this.hasNextPage,
    required this.nextOffset,
    this.isOffline = false,
    this.isLoadingMore = false,
  });

  final List<Pokemon> pokemonList;
  final bool hasNextPage;
  final int nextOffset;
  final bool isOffline;
  final bool isLoadingMore;

  PokemonListLoaded copyWith({
    List<Pokemon>? pokemonList,
    bool? hasNextPage,
    int? nextOffset,
    bool? isOffline,
    bool? isLoadingMore,
  }) {
    return PokemonListLoaded(
      pokemonList: pokemonList ?? this.pokemonList,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      nextOffset: nextOffset ?? this.nextOffset,
      isOffline: isOffline ?? this.isOffline,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        pokemonList,
        hasNextPage,
        nextOffset,
        isOffline,
        isLoadingMore,
      ];
}

/// Error state
class PokemonListError extends PokemonListState {
  const PokemonListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Empty state
class PokemonListEmpty extends PokemonListState {
  const PokemonListEmpty();
}


