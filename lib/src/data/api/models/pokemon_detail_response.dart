/// API response model for Pokémon detail
class PokemonDetailResponse {
  PokemonDetailResponse({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.sprites,
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonTypeSlot> types;
  final List<PokemonStatResponse> stats;
  final List<PokemonAbilitySlot> abilities;
  final PokemonSprites sprites;

  factory PokemonDetailResponse.fromJson(Map<String, dynamic> json) {
    return PokemonDetailResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List<dynamic>)
          .map((item) => PokemonTypeSlot.fromJson(item as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List<dynamic>)
          .map((item) => PokemonStatResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      abilities: (json['abilities'] as List<dynamic>)
          .map((item) => PokemonAbilitySlot.fromJson(item as Map<String, dynamic>))
          .toList(),
      sprites: PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
    );
  }
}

/// Type slot in Pokémon response
class PokemonTypeSlot {
  PokemonTypeSlot({
    required this.slot,
    required this.type,
  });

  final int slot;
  final PokemonType type;

  factory PokemonTypeSlot.fromJson(Map<String, dynamic> json) {
    return PokemonTypeSlot(
      slot: json['slot'] as int,
      type: PokemonType.fromJson(json['type'] as Map<String, dynamic>),
    );
  }
}

/// Type information
class PokemonType {
  PokemonType({
    required this.name,
  });

  final String name;

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      name: json['name'] as String,
    );
  }
}

/// Stat response model
class PokemonStatResponse {
  PokemonStatResponse({
    required this.baseStat,
    required this.stat,
  });

  final int baseStat;
  final PokemonStatInfo stat;

  factory PokemonStatResponse.fromJson(Map<String, dynamic> json) {
    return PokemonStatResponse(
      baseStat: json['base_stat'] as int,
      stat: PokemonStatInfo.fromJson(json['stat'] as Map<String, dynamic>),
    );
  }
}

/// Stat information
class PokemonStatInfo {
  PokemonStatInfo({
    required this.name,
  });

  final String name;

  factory PokemonStatInfo.fromJson(Map<String, dynamic> json) {
    return PokemonStatInfo(
      name: json['name'] as String,
    );
  }
}

/// Ability slot in Pokémon response
class PokemonAbilitySlot {
  PokemonAbilitySlot({
    required this.ability,
    required this.isHidden,
  });

  final PokemonAbility ability;
  final bool isHidden;

  factory PokemonAbilitySlot.fromJson(Map<String, dynamic> json) {
    return PokemonAbilitySlot(
      ability: PokemonAbility.fromJson(json['ability'] as Map<String, dynamic>),
      isHidden: json['is_hidden'] as bool,
    );
  }
}

/// Ability information
class PokemonAbility {
  PokemonAbility({
    required this.name,
  });

  final String name;

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(
      name: json['name'] as String,
    );
  }
}

/// Sprites (images) for Pokémon
class PokemonSprites {
  PokemonSprites({
    required this.frontDefault,
    this.frontShiny,
    this.backDefault,
    this.backShiny,
    this.other,
  });

  final String? frontDefault;
  final String? frontShiny;
  final String? backDefault;
  final String? backShiny;
  final PokemonSpritesOther? other;

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    return PokemonSprites(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
      backDefault: json['back_default'] as String?,
      backShiny: json['back_shiny'] as String?,
      other: json['other'] != null
          ? PokemonSpritesOther.fromJson(json['other'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Gets the best available image URL
  String? get bestImageUrl {
    return other?.officialArtwork?.frontDefault ??
        other?.dreamWorld?.frontDefault ??
        frontDefault;
  }

  /// Gets all available sprite URLs (only official-artwork images)
  List<String> get allSpriteUrls {
    final spriteList = [
      other?.officialArtwork?.frontDefault,
      other?.officialArtwork?.frontShiny,
    ].where((url) => url != null).cast<String>().toList();
    return spriteList;
  }
}

/// Other sprites
class PokemonSpritesOther {
  PokemonSpritesOther({
    this.dreamWorld,
    this.officialArtwork,
  });

  final PokemonSpritesDreamWorld? dreamWorld;
  final PokemonSpritesOfficialArtwork? officialArtwork;

  factory PokemonSpritesOther.fromJson(Map<String, dynamic> json) {
    return PokemonSpritesOther(
      dreamWorld: json['dream_world'] != null
          ? PokemonSpritesDreamWorld.fromJson(
              json['dream_world'] as Map<String, dynamic>,
            )
          : null,
      officialArtwork: json['official-artwork'] != null
          ? PokemonSpritesOfficialArtwork.fromJson(
              json['official-artwork'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Dream world sprites
class PokemonSpritesDreamWorld {
  PokemonSpritesDreamWorld({
    this.frontDefault,
  });

  final String? frontDefault;

  factory PokemonSpritesDreamWorld.fromJson(Map<String, dynamic> json) {
    return PokemonSpritesDreamWorld(
      frontDefault: json['front_default'] as String?,
    );
  }
}

/// Official artwork sprites
class PokemonSpritesOfficialArtwork {
  PokemonSpritesOfficialArtwork({
    this.frontDefault,
    this.frontShiny,
  });

  final String? frontDefault;
  final String? frontShiny;

  factory PokemonSpritesOfficialArtwork.fromJson(Map<String, dynamic> json) {
    return PokemonSpritesOfficialArtwork(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );
  }
}

