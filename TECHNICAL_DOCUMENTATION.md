# Technical Documentation

This document explains how the Pokémon Explorer app works under the hood. It's written for developers who want to understand or modify the code.

## Architecture

The app is split into three layers:

1. **Presentation** - The UI and user interactions
2. **Domain** - Business logic and data models
3. **Data** - API calls, database, and image processing

Each layer only talks to the layer below it. This keeps things organized and makes testing easier.

### Why this structure?

- Easy to test each part separately
- Easy to change one part without breaking others
- Clear separation of concerns

## Technology choices

**Flutter & Dart** - For building the app

**BLoC** - For managing app state. It's predictable and testable.

**GetIt** - For dependency injection. Makes it easy to swap implementations for testing.

**Dio** - For API calls. Has good error handling and retry logic.

**Drift** - For the database. Type-safe and generates code for you.

**sqlite3_flutter_libs** - Provides SQLite for mobile. Needed for Drift to work on Android/iOS.

**image package** - For resizing and compressing images.

## How data flows

### Loading the Pokémon list

1. User opens the app
2. Screen tells BLoC to load data
3. BLoC asks repository for data
4. Repository checks:
   - Is device online?
   - Is cached data fresh (less than 24 hours old)?
   - If yes to both, use cache
   - If cache is old or missing, fetch from API
5. Repository processes images and saves to cache
6. Repository returns data to BLoC
7. BLoC updates state
8. Screen rebuilds with new data

### Loading Pokémon details

Same flow, but for a single Pokémon. Also checks if we have complete detail data in cache.

## Database

### Why Drift?

- Type-safe queries (catches errors at compile time)
- Less boilerplate code
- Works on all platforms
- Good performance

### What's stored

The database has one main table: `PokemonTable`

- `id` - Pokémon ID (primary key)
- `name` - Pokémon name
- `imageUrl` - Original image URL
- `types` - JSON string of types
- `spriteUrls` - JSON string of sprite URLs
- `cachedAt` - When this was saved

### Database location

- Android: `/data/data/<package>/app_flutter/pokemon_explorer.db`
- iOS: `<App>/Documents/pokemon_explorer.db`

The database file is private to the app. Other apps can't access it.

### How it works

When the app starts, it creates a `LazyDatabase`. This means the database connection isn't opened until it's actually needed.

```dart
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final filePath = path.join(dbFolder.path, 'pokemon_explorer.db');
    return NativeDatabase(File(filePath));
  });
}
```

This works on both Android and iOS because `path_provider` handles the platform differences.

### Database operations

The `AppDatabase` class has methods for:
- Getting all Pokémon
- Getting a Pokémon by ID
- Getting Pokémon in a range (for pagination)
- Checking if a range exists
- Inserting/updating Pokémon
- Clearing the cache

All queries are type-safe thanks to Drift's code generation.

## API integration

### API client

The `PokemonApiClient` class handles all API calls. It uses Dio under the hood.

**Endpoints:**
- `GET /pokemon?offset=0&limit=20` - Get list of Pokémon
- `GET /pokemon/{id}` - Get Pokémon details

### Dio setup

Dio is configured with:
- Base URL: `https://pokeapi.co/api/v2/`
- 30 second timeout for connect and receive
- Two interceptors: one for logging, one for retries

**Logging interceptor:**
Logs every request, response, and error. Only works in debug mode.

**Retry interceptor:**
If a request fails due to timeout or connection error, it retries up to 2 times (3 total attempts). Each retry waits 2 seconds before attempting again.

### Error handling

When an API call fails, `NetworkUtils.handleDioError()` converts the Dio error into our custom `AppException`. This makes error handling consistent throughout the app.

Error types:
- `NetworkException` - Network problems
- `CacheException` - Cache problems (like offline with no cache)
- `ImageProcessingException` - Image processing problems
- `UnknownException` - Everything else

## Image processing

### Why process images?

Original images from the API are large. Processing them makes the app:
- Load faster
- Use less data
- Use less storage
- Work better offline

### How it works

1. Check if image is already cached
2. If not, download the image
3. Process it in a background thread (isolate):
   - Decode the image bytes
   - Resize to target size (256x256 or 512x512)
   - Encode as JPEG at 85% quality
   - Save to cache directory
4. Return the path to the cached image

### Why isolates?

Image processing is CPU-intensive. If we did it on the main thread, the UI would freeze. By using `compute()` to run it in an isolate, the UI stays smooth.

### Image sizes

- List view: 256x256 pixels
- Detail view: 512x512 pixels
- Quality: 85% (good balance between size and quality)

### Cache location

Images are cached in the app's cache directory:
- Android: `/data/data/<package>/cache/pokemon_images/`
- iOS: `<App>/Library/Caches/pokemon_images/`

The system can automatically clear this cache if storage is low.

## State management (BLoC)

### What is BLoC?

BLoC stands for Business Logic Component. It's a pattern for managing app state.

**Flow:**
1. User does something → Event
2. BLoC receives event → Processes it
3. BLoC emits new state
4. UI rebuilds with new state

### PokemonListBloc

**Events:**
- `LoadPokemonList` - Load the first page
- `LoadMorePokemon` - Load next page
- `RefreshPokemonList` - Refresh the list

**States:**
- `PokemonListInitial` - Starting state
- `PokemonListLoading` - Loading data
- `PokemonListLoaded` - Data loaded successfully (contains list, pagination info, offline flag)
- `PokemonListError` - Something went wrong
- `PokemonListEmpty` - No Pokémon found

### PokemonDetailBloc

**Events:**
- `LoadPokemonDetail` - Load details for a Pokémon (takes id parameter)
- `RefreshPokemonDetail` - Refresh the details (takes id parameter)

**States:**
- `PokemonDetailInitial` - Starting state
- `PokemonDetailLoading` - Loading data
- `PokemonDetailLoaded` - Data loaded successfully
- `PokemonDetailError` - Something went wrong

### Why BLoC?

- Predictable: Easy to see what events cause what states
- Testable: Easy to test by sending events and checking states
- Reusable: Same BLoC can be used in different screens
- No dependencies on Flutter: Can test without widgets

## Dependency injection

### What is GetIt?

GetIt is a service locator. It's like a registry where you can store and retrieve objects.

### How it's used

When the app starts, `setupDependencyInjection()` registers all the dependencies:

```dart
// Register as singleton (one instance for the whole app)
getIt.registerLazySingleton<Dio>(() => Dio(...));
getIt.registerLazySingleton<AppDatabase>(() => AppDatabase(...));

// Register as factory (new instance each time)
getIt.registerFactory<PokemonListBloc>(() => PokemonListBloc(...));
```

**Singleton vs Factory:**
- Singleton: One instance shared everywhere (like database, API client)
- Factory: New instance each time (like BLoC, so each screen has its own)

### Why use it?

- Easy to swap implementations (great for testing)
- No need to pass dependencies through constructors
- Lazy initialization (only creates when needed)

## Caching strategy

### Cache/Local-first approach

The app follows a cache/local-first strategy, prioritizing local data over network requests. It always checks the local cache first, then falls back to the API only when necessary.

**For list:**
1. Check if device is online
2. If online:
   - Check if cache has the requested page
   - Check if cache is fresh (less than 24 hours)
   - If both yes, use cache (local-first)
   - If no, fetch from API and update cache
   - If API fails, fall back to cache (even if stale)
3. If offline:
   - Use cache if available (local-first)
   - Show error if no cache

**For details:**
Same logic, but also checks if we have complete detail data (not just basic info). Always returns cached data if available and fresh, only fetching from API when cache is missing or stale.

### Cache freshness

Data is considered fresh for 24 hours. After that, it's fetched from the API again.

### Offline indicator

When showing cached data, the app shows a banner fixed below the AppBar (on both list and detail screens) saying "Offline Mode - Showing Cached Data". This lets users know the data might be outdated. The banner stays visible even when scrolling.

## Error handling

### Exception types

- `NetworkException` - Network problems (timeout, connection error, server error)
- `CacheException` - Cache problems (offline with no cache)
- `ImageProcessingException` - Image processing failures
- `UnknownException` - Everything else

### How errors are handled

1. Error happens in repository
2. Repository converts it to `AppException`
3. BLoC catches the exception
4. BLoC emits error state
5. UI shows error message with retry button

### User-friendly messages

Error messages are written in simple language, not technical jargon. For example:
- "Connection timeout. Please check your internet connection."
- "You're offline and there's no cached data available."

## Performance optimizations

### 1. Image processing in isolates

Images are processed in background threads so the UI doesn't freeze.

### 2. Image caching

Processed images are saved locally so they don't need to be downloaded or processed again.

### 3. Image optimization

Images are resized and compressed to reduce file size and memory usage.

### 4. BLoC buildWhen

Only rebuilds widgets when state actually changes, not on every state emission.

### 5. Scroll position preservation

Uses `PageStorageKey` to remember scroll position when the list refreshes.

### 6. Lazy database connection

Database connection is only opened when needed, not at app startup.

### 7. Batch database operations

Multiple inserts are done in a single transaction for better performance.

### 8. Pagination threshold

Starts loading more data when user is 90% down the list, so it's ready when they reach the bottom.

## Testing

### Test structure

Tests are organized by layer:
- `test/bloc/` - BLoC tests
- `test/repository/` - Repository tests
- `test/image_processing/` - Image processing tests

### What's tested

**BLoC tests:**
- Events trigger correct states
- Error handling works
- Pagination works
- Refresh works
- Offline flag is set correctly

**Repository tests:**
- Cache is used when fresh
- API is called when cache is stale
- Offline mode works
- Errors are handled correctly

**Image processor tests:**
- Images are processed correctly
- Cache is used when available
- Errors are handled

### Testing tools

- `bloc_test` - For testing BLoC
- `mocktail` - For mocking dependencies
- `mockito` - Alternative mocking framework

### Running tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific file
flutter test test/bloc/pokemon_list_bloc_test.dart
```

**Current status:** 34 tests, all passing

## Building the app

### Android

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
```

The APK will be in `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Before building

1. Run tests to make sure everything works
2. Generate database code: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Make sure all dependencies are installed: `flutter pub get`

## Platform differences

### Database

Both Android and iOS use the same code. `path_provider` handles the platform differences automatically.

**Android:** Uses `sqlite3_flutter_libs` to provide SQLite
**iOS:** Uses `sqlite3_flutter_libs` to provide SQLite

The database file location is different on each platform, but the code doesn't need to know about that.

### Image cache

Same code works on both platforms. `path_provider` gives us the right cache directory for each platform.

### Network

Both platforms support HTTPS by default. No special configuration needed.

## Common problems and solutions

### Database code won't generate

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Images not loading

- Check device storage space
- Make sure you have internet (for first download)
- Check if image URLs are valid

### Offline mode not working

- Make sure you've loaded data while online first
- Check if database file exists
- Verify connectivity detection

### Scroll position resets

Make sure `PageStorageKey` is set on the GridView:
```dart
GridView.builder(
  key: const PageStorageKey('pokemon_list'),
  // ...
)
```

### Too many rebuilds

Use `buildWhen` in BlocBuilder:
```dart
BlocBuilder<PokemonListBloc, PokemonListState>(
  buildWhen: (previous, current) => previous != current,
  // ...
)
```

## Future improvements

Some ideas for making the app better:

- Search functionality
- Favorite Pokémon
- Filter by type
- Compare Pokémon stats
- Show evolution chains
- Dark mode
- Multiple languages

## Summary

This app uses clean architecture with three layers: presentation, domain, and data. It uses BLoC for state management, Drift for the database, and processes images in background threads. The app follows a cache/local-first strategy, prioritizing local data over network requests. It works offline by caching data locally and shows a banner when using cached data.

The code is organized, testable, and follows Flutter best practices. All 34 tests are passing, and the app is ready for production use.

