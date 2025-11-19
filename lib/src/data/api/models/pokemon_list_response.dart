/// API response model for Pokémon list
class PokemonListResponse {
  PokemonListResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((item) => PokemonListItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Individual Pokémon item in list response
class PokemonListItem {
  PokemonListItem({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  /// Extracts Pokémon ID from URL
  int get id {
    final parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
  }
}


