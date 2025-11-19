import 'package:equatable/equatable.dart';

abstract class PokemonDetailEvent extends Equatable {
  const PokemonDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadPokemonDetail extends PokemonDetailEvent {
  const LoadPokemonDetail(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class RefreshPokemonDetail extends PokemonDetailEvent {
  const RefreshPokemonDetail(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}


