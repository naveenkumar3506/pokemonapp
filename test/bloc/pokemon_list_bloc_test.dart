import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemon_explorer/src/core/error/app_exception.dart';
import 'package:pokemon_explorer/src/domain/entities/pokemon.dart';
import 'package:pokemon_explorer/src/domain/repositories/pokemon_repository.dart';
import 'package:pokemon_explorer/src/presentation/bloc/pokemon_list/pokemon_list_bloc.dart';
import 'package:pokemon_explorer/src/presentation/bloc/pokemon_list/pokemon_list_event.dart';
import 'package:pokemon_explorer/src/presentation/bloc/pokemon_list/pokemon_list_state.dart';

class MockPokemonRepository extends Mock implements PokemonRepository {}

void main() {
  late MockPokemonRepository mockRepository;
  late PokemonListBloc bloc;

  setUp(() {
    mockRepository = MockPokemonRepository();
    bloc = PokemonListBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('PokemonListBloc', () {
    final testPokemonList = [
      const Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'https://example.com/1.png',
        types: ['grass', 'poison'],
      ),
      const Pokemon(
        id: 2,
        name: 'ivysaur',
        imageUrl: 'https://example.com/2.png',
        types: ['grass', 'poison'],
      ),
    ];

    final testResult = PokemonListResult(
      pokemonList: testPokemonList,
      hasNextPage: true,
      nextOffset: 20,
      isOffline: false,
    );

    test('initial state is PokemonListInitial', () {
      expect(bloc.state, equals(const PokemonListInitial()));
    });

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Loaded] when LoadPokemonList succeeds',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenAnswer((_) async => testResult);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonList()),
      expect: () => [
        const PokemonListLoading(),
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isOffline: false,
        ),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Empty] when LoadPokemonList returns empty list',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenAnswer((_) async => const PokemonListResult(
              pokemonList: [],
              hasNextPage: false,
              nextOffset: 0,
            ));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonList()),
      expect: () => [
        const PokemonListLoading(),
        const PokemonListEmpty(),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Error] when LoadPokemonList fails',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenThrow(const NetworkException('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonList()),
      expect: () => [
        const PokemonListLoading(),
        const PokemonListError('Network error'),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Error] when LoadPokemonList throws generic error',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenThrow(Exception('Unknown error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonList()),
      expect: () => [
        const PokemonListLoading(),
        const PokemonListError('Failed to load Pokémon: Exception: Unknown error'),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'does nothing when LoadMorePokemon called but no more pages',
      build: () {
        final loadedState = PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: false,
          nextOffset: 20,
        );
        return bloc;
      },
      seed: () => PokemonListLoaded(
        pokemonList: testPokemonList,
        hasNextPage: false,
        nextOffset: 20,
      ),
      act: (bloc) => bloc.add(const LoadMorePokemon()),
      expect: () => [],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'does nothing when LoadMorePokemon called while already loading',
      build: () {
        return bloc;
      },
      seed: () => PokemonListLoaded(
        pokemonList: testPokemonList,
        hasNextPage: true,
        nextOffset: 20,
        isLoadingMore: true,
      ),
      act: (bloc) => bloc.add(const LoadMorePokemon()),
      expect: () => [],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits updated state with more pokemon when LoadMorePokemon succeeds',
      build: () {
        final morePokemon = [
          const Pokemon(
            id: 3,
            name: 'venusaur',
            imageUrl: 'https://example.com/3.png',
            types: ['grass', 'poison'],
          ),
        ];
        when(() => mockRepository.getPokemonList(
              offset: 20,
              limit: 20,
            )).thenAnswer((_) async => PokemonListResult(
              pokemonList: morePokemon,
              hasNextPage: false,
              nextOffset: 40,
            ));
        return bloc;
      },
      seed: () => PokemonListLoaded(
        pokemonList: testPokemonList,
        hasNextPage: true,
        nextOffset: 20,
      ),
      act: (bloc) => bloc.add(const LoadMorePokemon()),
      expect: () => [
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isLoadingMore: true,
        ),
        PokemonListLoaded(
          pokemonList: [...testPokemonList, const Pokemon(
            id: 3,
            name: 'venusaur',
            imageUrl: 'https://example.com/3.png',
            types: ['grass', 'poison'],
          )],
          hasNextPage: false,
          nextOffset: 40,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits error when LoadMorePokemon fails',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 20,
              limit: 20,
            )).thenThrow(const NetworkException('Network error'));
        return bloc;
      },
      seed: () => PokemonListLoaded(
        pokemonList: testPokemonList,
        hasNextPage: true,
        nextOffset: 20,
      ),
      act: (bloc) => bloc.add(const LoadMorePokemon()),
      expect: () => [
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isLoadingMore: true,
        ),
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isLoadingMore: false,
        ),
        const PokemonListError('Network error'),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits [Loading, Loaded] when RefreshPokemonList succeeds from initial state',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenAnswer((_) async => testResult);
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshPokemonList()),
      expect: () => [
        const PokemonListLoading(),
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isOffline: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits updated state when RefreshPokemonList succeeds from loaded state',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenAnswer((_) async => testResult);
        return bloc;
      },
      seed: () => PokemonListLoaded(
        pokemonList: testPokemonList,
        hasNextPage: true,
        nextOffset: 20,
      ),
      act: (bloc) => bloc.add(const RefreshPokemonList()),
      expect: () => [
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isLoadingMore: true,
        ),
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isOffline: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'emits error when RefreshPokemonList fails',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenThrow(const NetworkException('Refresh failed'));
        return bloc;
      },
      seed: () => PokemonListLoaded(
        pokemonList: testPokemonList,
        hasNextPage: true,
        nextOffset: 20,
      ),
      act: (bloc) => bloc.add(const RefreshPokemonList()),
      expect: () => [
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isLoadingMore: true,
        ),
        const PokemonListError('Refresh failed'),
      ],
    );

    blocTest<PokemonListBloc, PokemonListState>(
      'shows offline flag when data comes from cache',
      build: () {
        when(() => mockRepository.getPokemonList(
              offset: 0,
              limit: 20,
            )).thenAnswer((_) async => PokemonListResult(
              pokemonList: testPokemonList,
              hasNextPage: true,
              nextOffset: 20,
              isOffline: true,
            ));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonList()),
      expect: () => [
        const PokemonListLoading(),
        PokemonListLoaded(
          pokemonList: testPokemonList,
          hasNextPage: true,
          nextOffset: 20,
          isOffline: true,
        ),
      ],
    );
  });
}

