import 'package:equatable/equatable.dart';

abstract class PokemonListEvent extends Equatable {
  const PokemonListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPokemonList extends PokemonListEvent {
  const LoadPokemonList();
}

class LoadMorePokemon extends PokemonListEvent {
  const LoadMorePokemon();
}

class RefreshPokemonList extends PokemonListEvent {
  const RefreshPokemonList();
}


