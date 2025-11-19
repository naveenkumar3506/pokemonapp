/// API constants
class ApiConstants {
  ApiConstants._();

  /// Base URL for PokéAPI v2
  static const String baseUrl = 'https://pokeapi.co/api/v2/';
  
  /// Request timeout in milliseconds
  static const int timeoutMs = 30000;
  
  /// Cache freshness limit in hours
  static const int cacheFreshnessHours = 24;
  
  /// Image dimensions
  static const int listImageSize = 256;
  static const int detailImageSize = 512;
  static const int thumbnailSize = 128;
  
  /// Image compression quality (0-100)
  static const int imageQuality = 85;
  
  /// Base URL for Pokémon sprite images
  static const String spriteBaseUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';
  
  /// Generates the official artwork image URL for a Pokémon by ID
  static String getPokemonImageUrl(int id) {
    return '$spriteBaseUrl/$id.png';
  }
}


