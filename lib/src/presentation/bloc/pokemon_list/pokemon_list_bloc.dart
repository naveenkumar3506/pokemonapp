import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pokemon_repository.dart';
import '../../../domain/entities/pokemon.dart';
import '../../../core/error/app_exception.dart';
import 'pokemon_list_event.dart';
import 'pokemon_list_state.dart';

class PokemonListBloc extends Bloc<PokemonListEvent, PokemonListState> {
  PokemonListBloc(this._repository) : super(const PokemonListInitial()) {
    on<LoadPokemonList>(_onLoadPokemonList);
    on<LoadMorePokemon>(_onLoadMorePokemon);
    on<RefreshPokemonList>(_onRefreshPokemonList);
  }

  final PokemonRepository _repository;

  /// Handles errors and emits appropriate error state
  void _handleError(
    Object error,
    Emitter<PokemonListState> emit,
    String defaultMessage,
  ) {
    if (error is AppException) {
      emit(PokemonListError(error.message));
    } else {
      emit(PokemonListError(defaultMessage));
    }
  }

  /// Creates loaded state from repository result
  PokemonListState _createLoadedState(PokemonListResult result) {
    if (result.pokemonList.isEmpty) {
      return const PokemonListEmpty();
    }

    return PokemonListLoaded(
      pokemonList: result.pokemonList,
      hasNextPage: result.hasNextPage,
      nextOffset: result.nextOffset,
      isOffline: result.isOffline,
    );
  }

  /// Loads initial Pokémon list
  Future<void> _loadInitialList(Emitter<PokemonListState> emit) async {
    emit(const PokemonListLoading());
    try {
      final result = await _repository.getPokemonList(offset: 0, limit: 20);
      emit(_createLoadedState(result));
    } catch (e) {
      _handleError(e, emit, 'Failed to load Pokémon: ${e.toString()}');
    }
  }

  /// Checks if more Pokémon can be loaded
  bool _canLoadMore(PokemonListLoaded state) {
    return state.hasNextPage && !state.isLoadingMore;
  }

  /// Appends new Pokémon to existing list
  List<Pokemon> _appendPokemonList(
    List<Pokemon> currentList,
    List<Pokemon> newList,
  ) {
    return [...currentList, ...newList];
  }

  /// Loads more Pokémon for pagination
  Future<void> _loadMorePokemon(
    PokemonListLoaded currentState,
    Emitter<PokemonListState> emit,
  ) async {
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await _repository.getPokemonList(
        offset: currentState.nextOffset,
        limit: 20,
      );

      final updatedList = _appendPokemonList(
        currentState.pokemonList,
        result.pokemonList,
      );

      emit(currentState.copyWith(
        pokemonList: updatedList,
        hasNextPage: result.hasNextPage,
        nextOffset: result.nextOffset,
        isOffline: result.isOffline,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      _handleError(e, emit, 'Failed to load more: ${e.toString()}');
    }
  }

  Future<void> _onLoadPokemonList(
    LoadPokemonList event,
    Emitter<PokemonListState> emit,
  ) async {
    await _loadInitialList(emit);
  }

  Future<void> _onLoadMorePokemon(
    LoadMorePokemon event,
    Emitter<PokemonListState> emit,
  ) async {
    final currentState = state;
    if (currentState is PokemonListLoaded) {
      if (!_canLoadMore(currentState)) {
        return;
      }
      await _loadMorePokemon(currentState, emit);
    }
  }

  Future<void> _onRefreshPokemonList(
    RefreshPokemonList event,
    Emitter<PokemonListState> emit,
  ) async {
    final currentState = state;
    if (currentState is PokemonListLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(const PokemonListLoading());
    }

    try {
      final result = await _repository.getPokemonList(offset: 0, limit: 20);
      emit(PokemonListLoaded(
        pokemonList: result.pokemonList,
        hasNextPage: result.hasNextPage,
        nextOffset: result.nextOffset,
        isOffline: result.isOffline,
        isLoadingMore: false,
      ));
    } catch (e) {
      _handleError(e, emit, 'Refresh failed: ${e.toString()}');
    }
  }
}



