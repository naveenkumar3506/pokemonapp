# Pokémon Explorer
A Flutter app to browse Pokémon data from PokéAPI. Works offline, loads images fast, and has a clean UI.

## What it does
- Shows a list of Pokémon with infinite scroll
- Shows detailed info about each Pokémon
- Works without internet (uses cached data)
- Images are optimized and cached
- Swipe through multiple Pokemon images
- Smooth scrolling that remembers your position
- Quick button to scroll back to top

- **Paginated Pokémon List**: Infinite scrolling with pull-to-refresh
- **Pokémon Details**: Comprehensive information including stats, types, abilities, and multiple sprites
- **Offline Support**: Full offline functionality with cached data and offline indicators
- **Image Optimization**: Automatic image resizing, compression, and caching using background isolates
- **Carousel Slider**: Swipeable image carousel with page indicators for multiple sprites
- **Smooth Scrolling**: Optimized GridView with preserved scroll position
- **Scroll to Top**: Quick navigation button that appears when scrolling down

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/src/
├── presentation/          # UI Layer
│   ├── screens/           # Screen widgets
│   ├── widgets/           # Reusable widgets
│   └── bloc/             # State management (BLoC pattern)
├── domain/               # Business Logic Layer
│   ├── entities/          # Domain models
│   └── repositories/      # Repository interfaces
└── data/                 # Data Layer
    ├── api/              # API client and models
    ├── db/               # Database (Drift)
    ├── repository_impl/  # Repository implementations
    ├── mappers/          # Data mappers
    └── image_processing/ # Image optimization
```

### Architecture Principles

- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Inversion**: Domain layer doesn't depend on data layer
- **Repository Pattern**: Single source of truth for data operations
- **BLoC Pattern**: Predictable state management
- **Cache/Local-First Strategy**: Prioritizes local cache, falls back to API when needed

## 🛠️ Tech Stack

### Core Dependencies

- **Flutter**: UI framework
- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **dio**: HTTP client with interceptors
- **drift**: Type-safe SQLite database
- **connectivity_plus**: Network connectivity detection
- **image**: Image processing and optimization
- **carousel_slider**: Image carousel widget

### Development Dependencies

- **bloc_test**: BLoC testing utilities
- **mocktail**: Mocking framework for tests
- **flutter_lints**: Linting rules
- **drift_dev**: Database code generation
- **build_runner**: Code generation

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pokemon_explorer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate database code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/bloc/
flutter test test/repository/
flutter test test/image_processing/

# Run tests with coverage
flutter test --coverage
```

### Test Coverage

- **BLoC Tests**: 19/19 passing (100% coverage)
  - Event handling (fetch, paginate, refresh)
  - State transitions
  - Error handling
  - Offline flag handling

- **Repository Tests**: 8/8 passing
  - Cache vs API logic
  - Offline scenarios
  - Error handling

- **Image Processor Tests**: 4/4 passing
  - Image processing functions
  - Cache management

- **Offline/Online Tests**: 2/2 passing
  - Connectivity state switching

### Overall Test Status

✅ **34 tests passing** (100% pass rate)

## 📦 Building the App

### Android APK

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

### iOS

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## 📂 Project Structure

```
lib/src/
├── core/
│   ├── constants/        # API constants, image sizes
│   ├── di/               # Dependency injection setup
│   ├── error/            # Custom exception classes
│   └── utils/            # Utility functions
├── data/
│   ├── api/              # API client and response models
│   ├── db/               # Database schema and DAOs
│   ├── image_processing/ # Image download, resize, cache
│   ├── mappers/          # Entity ↔ Model mappers
│   └── repository_impl/  # Repository implementations
├── domain/
│   ├── entities/         # Business entities
│   └── repositories/     # Repository interfaces
└── presentation/
    ├── bloc/             # BLoC state management
    ├── screens/          # Screen widgets
    └── widgets/          # Reusable UI components
```

## 🔑 Key Features Explained

### Offline Support

- **Cache/Local-First Strategy**: Always checks local cache first, uses API only when cache is missing or stale
- **24-Hour Freshness**: Cached data is considered fresh for 24 hours
- **Offline Indicators**: Visual banners show when cached data is displayed
- **Automatic Fallback**: Falls back to cache when API calls fail

### Image Optimization

- **Background Processing**: All image operations run in isolates using `compute()`
- **Automatic Resizing**: 
  - List view: 256x256 pixels
  - Detail view: 512x512 pixels
  - Thumbnails: 128x128 pixels
- **Compression**: JPEG images compressed at 85% quality
- **Local Caching**: Processed images cached on device

### Pagination

- **Infinite Scrolling**: Automatically loads more Pokémon when scrolling near the bottom (90% threshold)
- **Scroll Position Preservation**: GridView maintains scroll position across rebuilds
- **Load More Indicator**: Visual feedback when loading additional data

### State Management

- **BLoC Pattern**: Predictable state management with clear event → state flows
- **Optimized Rebuilds**: `buildWhen` conditions prevent unnecessary widget rebuilds
- **Error Handling**: Comprehensive error states with user-friendly messages

## 🎨 UI/UX Features

- **Material Design 3**: Modern Material Design implementation
- **SafeArea**: Proper handling of device notches and system bars
- **Carousel Slider**: Swipeable image gallery with page indicators
- **Scroll to Top**: Floating action button for quick navigation
- **Pull to Refresh**: Refresh data by pulling down on the list
- **Loading States**: Clear loading indicators for better UX
- **Error States**: User-friendly error messages with retry options

## 🔧 Configuration

### API Configuration

API settings are configured in `lib/src/core/constants/api_constants.dart`:

- **Base URL**: `https://pokeapi.co/api/v2/`
- **Timeout**: 30 seconds
- **Cache Freshness**: 24 hours

### Image Configuration

- **List Image Size**: 256x256 pixels
- **Detail Image Size**: 512x512 pixels
- **Thumbnail Size**: 128x128 pixels
- **Compression Quality**: 85%

## 📝 Code Standards

- **Null Safety**: All code uses Dart null safety
- **Linting**: Follows `flutter_lints` rules
- **Formatting**: Consistent code formatting via `dartfmt`
- **Function Size**: Functions are kept small and focused
- **Documentation**: Key functions and classes are documented

## 🚫 Constraints

- **State Management**: BLoC only (Provider/Riverpod not allowed)
- **Database**: Drift only (sqflite not allowed)
- **Business Logic**: No business logic in Widgets (use BLoC)

## 🐛 Troubleshooting

### Database Generation Issues

If you encounter database generation errors:

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Image Processing Errors

If images fail to process:
- Check device storage permissions
- Verify network connectivity for image downloads
- Check image URL validity

### Offline Mode Issues

If offline mode doesn't work:
- Ensure database is properly initialized
- Check that data has been cached previously
- Verify connectivity detection is working

## 👥 Contributing

1. Follow the existing code structure and patterns
2. Write tests for new features
3. Ensure all tests pass before submitting
4. Follow the coding standards and linting rules

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Drift Database](https://drift.simonbinder.eu/)
- [PokéAPI Documentation](https://pokeapi.co/docs/v2)
