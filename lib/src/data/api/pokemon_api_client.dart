import 'package:dio/dio.dart';
import '../../core/error/app_exception.dart';
import '../../core/utils/network_utils.dart';
import 'models/pokemon_list_response.dart';
import 'models/pokemon_detail_response.dart';

/// API client for Pokémon API
class PokemonApiClient {
  PokemonApiClient(this._dio);

  final Dio _dio;

  /// Fetches paginated list of Pokémon
  Future<PokemonListResponse> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'pokemon',
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );
      return PokemonListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkUtils.handleDioError(e);
    } catch (e) {
      throw const UnknownException('Failed to fetch Pokémon list');
    }
  }

  /// Fetches detailed information for a specific Pokémon
  Future<PokemonDetailResponse> getPokemonById(int id) async {
    try {
      final response = await _dio.get('pokemon/$id');
      return PokemonDetailResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkUtils.handleDioError(e);
    } catch (e) {
      throw const UnknownException('Failed to fetch Pokémon details');
    }
  }
}

