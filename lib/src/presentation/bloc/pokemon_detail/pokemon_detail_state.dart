import 'package:equatable/equatable.dart';
import '../../../domain/entities/pokemon.dart';

/// States for Pokémon detail BLoC
abstract class PokemonDetailState extends Equatable {
  const PokemonDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PokemonDetailInitial extends PokemonDetailState {
  const PokemonDetailInitial();
}

/// Loading state
class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();
}

/// Loaded state with Pokémon details
class PokemonDetailLoaded extends PokemonDetailState {
  const PokemonDetailLoaded({
    required this.pokemon,
  });

  final Pokemon pokemon;

  @override
  List<Object?> get props => [pokemon];
}

/// Error state
class PokemonDetailError extends PokemonDetailState {
  const PokemonDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}


