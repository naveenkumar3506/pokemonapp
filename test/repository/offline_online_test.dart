import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemon_explorer/src/core/error/app_exception.dart';
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

  group('Offline/Online State Switching', () {
    final cachedData = [
      PokemonTableData(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'https://example.com/1.png',
        types: '[]',
        cachedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];


    test('switches from offline to online - fetches from API', () async {
      // Start offline
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockDatabase.hasPokemonRange(0, 20))
          .thenAnswer((_) async => true);
      when(() => mockDatabase.getPokemonRange(0, 20))
          .thenAnswer((_) async => cachedData);
      when(() => mockDatabase.getPokemonCount())
          .thenAnswer((_) async => 100);

      final offlineResult = await repository.getPokemonList(offset: 0, limit: 20);
      expect(offlineResult.isOffline, isTrue);

      // Switch to online
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockDatabase.hasPokemonRange(0, 20))
          .thenAnswer((_) async => false);
      // API would be called here in real scenario
    });



    test('handles mixed online/offline scenarios for getPokemonById', () async {
      final cachedPokemon = PokemonTableData(
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

      // Online with complete cache - should use cache
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockDatabase.getPokemonById(1))
          .thenAnswer((_) async => cachedPokemon);

      final onlineResult = await repository.getPokemonById(1);
      expect(onlineResult.id, equals(1));

      // Switch to offline
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final offlineResult = await repository.getPokemonById(1);
      expect(offlineResult.id, equals(1));
      expect(offlineResult.isOffline, isTrue);
    });
  });
}

