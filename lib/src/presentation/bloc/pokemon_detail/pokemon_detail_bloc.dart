import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pokemon_repository.dart';
import '../../../core/error/app_exception.dart';
import 'pokemon_detail_event.dart';
import 'pokemon_detail_state.dart';

class PokemonDetailBloc extends Bloc<PokemonDetailEvent, PokemonDetailState> {
  PokemonDetailBloc(this._repository) : super(const PokemonDetailInitial()) {
    on<LoadPokemonDetail>(_onLoadPokemonDetail);
    on<RefreshPokemonDetail>(_onRefreshPokemonDetail);
  }

  final PokemonRepository _repository;

  /// Handles errors and emits appropriate error state
  void _handleError(
    Object error,
    Emitter<PokemonDetailState> emit,
    String defaultMessage,
  ) {
    if (error is AppException) {
      emit(PokemonDetailError(error.message));
    } else {
      emit(PokemonDetailError(defaultMessage));
    }
  }

  /// Loads Pokémon detail and handles state transitions
  Future<void> _loadPokemonDetail(
    int id,
    Emitter<PokemonDetailState> emit,
  ) async {
    emit(const PokemonDetailLoading());
    try {
      final pokemon = await _repository.getPokemonById(id);
      emit(PokemonDetailLoaded(pokemon: pokemon));
    } catch (e) {
      _handleError(e, emit, 'Failed to load details: ${e.toString()}');
    }
  }

  Future<void> _onLoadPokemonDetail(
    LoadPokemonDetail event,
    Emitter<PokemonDetailState> emit,
  ) async {
    await _loadPokemonDetail(event.id, emit);
  }

  Future<void> _onRefreshPokemonDetail(
    RefreshPokemonDetail event,
    Emitter<PokemonDetailState> emit,
  ) async {
    await _loadPokemonDetail(event.id, emit);
  }
}


