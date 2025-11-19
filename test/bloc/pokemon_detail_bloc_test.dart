import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemon_explorer/src/core/error/app_exception.dart';
import 'package:pokemon_explorer/src/domain/entities/pokemon.dart';
import 'package:pokemon_explorer/src/domain/repositories/pokemon_repository.dart';
import 'package:pokemon_explorer/src/presentation/bloc/pokemon_detail/pokemon_detail_bloc.dart';
import 'package:pokemon_explorer/src/presentation/bloc/pokemon_detail/pokemon_detail_event.dart';
import 'package:pokemon_explorer/src/presentation/bloc/pokemon_detail/pokemon_detail_state.dart';

class MockPokemonRepository extends Mock implements PokemonRepository {}

void main() {
  late MockPokemonRepository mockRepository;
  late PokemonDetailBloc bloc;

  setUp(() {
    mockRepository = MockPokemonRepository();
    bloc = PokemonDetailBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('PokemonDetailBloc', () {
    const testPokemon = Pokemon(
      id: 1,
      name: 'bulbasaur',
      imageUrl: 'https://example.com/1.png',
      types: ['grass', 'poison'],
      height: 7,
      weight: 69,
      stats: [
        PokemonStat(name: 'hp', value: 80),
        PokemonStat(name: 'attack', value: 50),
      ],
      abilities: ['overgrow', 'chlorophyll'],
    );

    test('initial state is PokemonDetailInitial', () {
      expect(bloc.state, equals(const PokemonDetailInitial()));
    });

    blocTest<PokemonDetailBloc, PokemonDetailState>(
      'emits [Loading, Loaded] when LoadPokemonDetail succeeds',
      build: () {
        when(() => mockRepository.getPokemonById(1))
            .thenAnswer((_) async => testPokemon);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonDetail(1)),
      expect: () => [
        const PokemonDetailLoading(),
        PokemonDetailLoaded(pokemon: testPokemon),
      ],
    );

    blocTest<PokemonDetailBloc, PokemonDetailState>(
      'emits [Loading, Error] when LoadPokemonDetail fails with AppException',
      build: () {
        when(() => mockRepository.getPokemonById(1))
            .thenThrow(const NetworkException('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonDetail(1)),
      expect: () => [
        const PokemonDetailLoading(),
        const PokemonDetailError('Network error'),
      ],
    );

    blocTest<PokemonDetailBloc, PokemonDetailState>(
      'emits [Loading, Error] when LoadPokemonDetail fails with generic error',
      build: () {
        when(() => mockRepository.getPokemonById(1))
            .thenThrow(Exception('Unknown error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPokemonDetail(1)),
      expect: () => [
        const PokemonDetailLoading(),
        const PokemonDetailError('Failed to load details: Exception: Unknown error'),
      ],
    );

    blocTest<PokemonDetailBloc, PokemonDetailState>(
      'emits [Loading, Loaded] when RefreshPokemonDetail succeeds',
      build: () {
        when(() => mockRepository.getPokemonById(1))
            .thenAnswer((_) async => testPokemon);
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshPokemonDetail(1)),
      expect: () => [
        const PokemonDetailLoading(),
        PokemonDetailLoaded(pokemon: testPokemon),
      ],
    );

    blocTest<PokemonDetailBloc, PokemonDetailState>(
      'emits [Loading, Error] when RefreshPokemonDetail fails',
      build: () {
        when(() => mockRepository.getPokemonById(1))
            .thenThrow(const CacheException('Cache error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshPokemonDetail(1)),
      expect: () => [
        const PokemonDetailLoading(),
        const PokemonDetailError('Cache error'),
      ],
    );
  });
}

