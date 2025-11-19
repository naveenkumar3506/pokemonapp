import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemon_explorer/src/core/constants/api_constants.dart';
import 'package:pokemon_explorer/src/core/error/app_exception.dart';
import 'package:pokemon_explorer/src/data/api/models/pokemon_detail_response.dart';
import 'package:pokemon_explorer/src/data/api/models/pokemon_list_response.dart';
import 'package:pokemon_explorer/src/data/api/pokemon_api_client.dart';
import 'package:pokemon_explorer/src/data/db/app_database.dart';
import 'package:pokemon_explorer/src/data/image_processing/image_processor.dart';
import 'package:pokemon_explorer/src/data/repository_impl/pokemon_repository_impl.dart';
import 'package:pokemon_explorer/src/domain/entities/pokemon.dart';

class MockPokemonApiClient extends Mock implements PokemonApiClient {}
class MockAppDatabase extends Mock implements AppDatabase {}
class MockImageProcessor extends Mock implements ImageProcessor {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(PokemonTableCompanion.insert(
      name: 'test',
      imageUrl: 'test',
      types: '[]',
      cachedAt: DateTime.now(),
    ));
  });
  late MockPokemonApiClient mockApiClient;
  late MockAppDatabase mockDatabase;
  late MockImageProcessor mockImageProcessor;
  late MockConnectivity mockConnectivity;
  late PokemonRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockPokemonApiClient();
    mockDatabase = MockAppDatabase();
    mockImageProcessor = MockImageProcessor();
    mockConnectivity = MockConnectivity();
    repository = PokemonRepositoryImpl(
      apiClient: mockApiClient,
      database: mockDatabase,
      imageProcessor: mockImageProcessor,
      connectivity: mockConnectivity,
    );
  });

  group('PokemonRepositoryImpl - getPokemonList', () {
    final testApiResponse = PokemonListResponse(
      count: 100,
      next: 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20',
      previous: null,
      results: [
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/'),
        PokemonListItem(name: 'ivysaur', url: 'https://pokeapi.co/api/v2/pokemon/2/'),
      ],
    );

    final testPokemonList = [
      const Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'https://example.com/1.png',
        types: [],
      ),
      const Pokemon(
        id: 2,
        name: 'ivysaur',
        imageUrl: 'https://example.com/2.png',
        types: [],
      ),
    ];

    test('fetches from API when online and no cache', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockDatabase.hasPokemonRange(0, 20))
          .thenAnswer((_) async => false);
      when(() => mockApiClient.getPokemonList(offset: 0, limit: 20))
          .thenAnswer((_) async => testApiResponse);
      when(() => mockImageProcessor.processAndCacheImage(
            imageUrl: any(named: 'imageUrl'),
            targetSize: ApiConstants.listImageSize,
          )).thenAnswer((_) async => '/cache/path/1.png');
      when(() => mockDatabase.insertOrUpdatePokemonList(any()))
          .thenAnswer((_) async => {});

      final result = await repository.getPokemonList(offset: 0, limit: 20);

      expect(result.pokemonList.length, equals(2));
      expect(result.hasNextPage, isTrue);
      expect(result.isOffline, isFalse);
      verify(() => mockApiClient.getPokemonList(offset: 0, limit: 20)).called(1);
      verify(() => mockDatabase.insertOrUpdatePokemonList(any())).called(greaterThanOrEqualTo(1));
    });

    test('uses cache when online and cache is fresh', () async {
      final cachedData = [
        PokemonTableData(
          id: 1,
          name: 'bulbasaur',
          imageUrl: 'https://example.com/1.png',
          types: '[]',
          cachedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockDatabase.hasPokemonRange(0, 20))
          .thenAnswer((_) async => true);
      when(() => mockDatabase.getPokemonRange(0, 20))
          .thenAnswer((_) async => cachedData);
      when(() => mockDatabase.getPokemonCount())
          .thenAnswer((_) async => 100);
      // API is called to check pagination even when using cache
      when(() => mockApiClient.getPokemonList(offset: 0, limit: 20))
          .thenAnswer((_) async => testApiResponse);

      final result = await repository.getPokemonList(offset: 0, limit: 20);

      expect(result.pokemonList.length, equals(1));
      expect(result.isOffline, isTrue); // Shows offline banner when using cache
      // getPokemonRange is called twice: once in _shouldUseCachedPage, once in _getPokemonListFromCache
      verify(() => mockDatabase.getPokemonRange(0, 20)).called(2);
    });

    test('uses cache when offline', () async {
      final cachedData = [
        PokemonTableData(
          id: 1,
          name: 'bulbasaur',
          imageUrl: 'https://example.com/1.png',
          types: '[]',
          cachedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockDatabase.hasPokemonRange(0, 20))
          .thenAnswer((_) async => true);
      when(() => mockDatabase.getPokemonRange(0, 20))
          .thenAnswer((_) async => cachedData);
      when(() => mockDatabase.getPokemonCount())
          .thenAnswer((_) async => 100);

      final result = await repository.getPokemonList(offset: 0, limit: 20);

      expect(result.pokemonList.length, equals(1));
      expect(result.isOffline, isTrue);
      // getPokemonRange is called in _getPokemonListFromCache
      verify(() => mockDatabase.getPokemonRange(0, 20)).called(greaterThanOrEqualTo(1));
    });

    test('throws CacheException when offline and no cache', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockDatabase.hasPokemonRange(0, 20))
          .thenAnswer((_) async => false);
      when(() => mockDatabase.getAllPokemon())
          .thenAnswer((_) async => []);

      expect(
        () => repository.getPokemonList(offset: 0, limit: 20),
        throwsA(isA<CacheException>()),
      );
    });

  });

  group('PokemonRepositoryImpl - getPokemonById', () {
    final testDetailResponse = PokemonDetailResponse(
      id: 1,
      name: 'bulbasaur',
      height: 7,
      weight: 69,
      types: [],
      stats: [],
      abilities: [],
      sprites: PokemonSprites(
        frontDefault: 'https://example.com/1.png',
        other: PokemonSpritesOther(
          officialArtwork: PokemonSpritesOfficialArtwork(
            frontDefault: 'https://example.com/official/1.png',
            frontShiny: 'https://example.com/official/shiny/1.png',
          ),
        ),
      ),
    );

    test('fetches from API when online and no complete cache', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockDatabase.getPokemonById(1))
          .thenAnswer((_) async => null);
      when(() => mockApiClient.getPokemonById(1))
          .thenAnswer((_) async => testDetailResponse);
      when(() => mockImageProcessor.processAndCacheImage(
            imageUrl: any(named: 'imageUrl'),
            targetSize: ApiConstants.detailImageSize,
          )).thenAnswer((_) async => '/cache/path/1.png');
      when(() => mockDatabase.insertOrUpdatePokemon(any()))
          .thenAnswer((_) async => {});

      final result = await repository.getPokemonById(1);

      expect(result.id, equals(1));
      expect(result.name, equals('bulbasaur'));
      verify(() => mockApiClient.getPokemonById(1)).called(1);
    });

    test('uses cache when offline', () async {
      final cachedData = PokemonTableData(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'https://example.com/1.png',
        types: '["grass", "poison"]',
        height: 7,
        weight: 69,
        stats: '[{"name":"hp","value":45}]',
        abilities: '["overgrow"]',
        cachedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockDatabase.getPokemonById(1))
          .thenAnswer((_) async => cachedData);

      final result = await repository.getPokemonById(1);

      expect(result.id, equals(1));
      expect(result.name, equals('bulbasaur'));
      verifyNever(() => mockApiClient.getPokemonById(any()));
    });

    test('throws CacheException when offline and no cache', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockDatabase.getPokemonById(1))
          .thenAnswer((_) async => null);

      expect(
        () => repository.getPokemonById(1),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('PokemonRepositoryImpl - refreshCache', () {
    test('throws NetworkException when offline', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      expect(
        () => repository.refreshCache(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('clears cache and fetches fresh data when online', () async {
      final testApiResponse = PokemonListResponse(
        count: 20,
        next: null,
        previous: null,
        results: [
          PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/'),
        ],
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockDatabase.clearCache())
          .thenAnswer((_) async => {});
      when(() => mockImageProcessor.clearCache())
          .thenAnswer((_) async => {});
      when(() => mockDatabase.hasPokemonRange(any(), any()))
          .thenAnswer((_) async => false);
      when(() => mockApiClient.getPokemonList(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => testApiResponse);
      when(() => mockImageProcessor.processAndCacheImage(
            imageUrl: any(named: 'imageUrl'),
            targetSize: any(named: 'targetSize'),
          )).thenAnswer((_) async => '/cache/path/1.png');
      when(() => mockDatabase.insertOrUpdatePokemonList(any()))
          .thenAnswer((_) async => {});

      await repository.refreshCache();

      verify(() => mockDatabase.clearCache()).called(1);
      verify(() => mockImageProcessor.clearCache()).called(1);
    });
  });
}

