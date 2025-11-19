import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../../data/api/pokemon_api_client.dart';
import '../../data/db/app_database.dart';
import '../../data/repository_impl/pokemon_repository_impl.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../data/image_processing/image_processor.dart';
import '../../presentation/bloc/pokemon_list/pokemon_list_bloc.dart';
import '../../presentation/bloc/pokemon_detail/pokemon_detail_bloc.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection container
Future<void> setupDependencyInjection() async {
  // Core dependencies
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // Dio HTTP client
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.timeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.timeoutMs),
      ),
    );
    
    // Request/response logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('Error ${error.response?.statusCode} ${error.requestOptions.path}');
          handler.next(error);
        },
      ),
    );
    
    // Retry on network failures (up to 2 retries)
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            // Get current retry count from request options
            final retryCount = (error.requestOptions.extra['retryCount'] as int?) ?? 0;
            const maxRetries = 2;
            
            // Only retry if we haven't exceeded max retries
            if (retryCount < maxRetries) {
              // Wait before retrying
              await Future.delayed(const Duration(seconds: 2));
              
              // Increment retry count and update request options
              error.requestOptions.extra['retryCount'] = retryCount + 1;
              
              try {
                final retryResponse = await dio.fetch(error.requestOptions);
                handler.resolve(retryResponse);
              } catch (e) {
                // If retry also fails, create a new DioException with updated retry count
                if (e is DioException) {
                  final newError = DioException(
                    requestOptions: error.requestOptions,
                    type: e.type,
                    error: e.error,
                    response: e.response,
                  );
                  // Recursively call handler to trigger another retry attempt
                  handler.next(newError);
                } else {
                  handler.next(error);
                }
              }
            } else {
              // Max retries reached, pass the error forward
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
    
    return dio;
  });
  
  // Database
  getIt.registerLazySingleton<AppDatabase>(() {
    return AppDatabase(_openConnection());
  });
  
  // Image processor
  getIt.registerLazySingleton<ImageProcessor>(() => ImageProcessor());
  
  // API client
  getIt.registerLazySingleton<PokemonApiClient>(
    () => PokemonApiClient(getIt<Dio>()),
  );
  
  // Repository
  getIt.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(
      apiClient: getIt<PokemonApiClient>(),
      database: getIt<AppDatabase>(),
      imageProcessor: getIt<ImageProcessor>(),
      connectivity: getIt<Connectivity>(),
    ),
  );
  
  // BLoCs - using factory for each instance
  getIt.registerFactory<PokemonListBloc>(
    () => PokemonListBloc(getIt<PokemonRepository>()),
  );
  
  getIt.registerFactory<PokemonDetailBloc>(
    () => PokemonDetailBloc(getIt<PokemonRepository>()),
  );
}

/// Opens a database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final filePath = path.join(dbFolder.path, 'pokemon_explorer.db');
    return NativeDatabase(File(filePath));
  });
}

