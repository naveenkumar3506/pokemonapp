import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import '../../core/di/injection_container.dart' as di;
import '../bloc/pokemon_detail/pokemon_detail_bloc.dart';
import '../bloc/pokemon_detail/pokemon_detail_event.dart';
import '../bloc/pokemon_detail/pokemon_detail_state.dart';
import '../widgets/offline_banner.dart';
import '../../domain/entities/pokemon.dart';

/// Screen displaying detailed information about a Pokémon
class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({
    super.key,
    required this.pokemonId,
  });

  final int pokemonId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<PokemonDetailBloc>()
        ..add(LoadPokemonDetail(pokemonId)),
      child: BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
        builder: (context, state) {
          if (state is PokemonDetailLoading) {
            return Scaffold(
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is PokemonDetailError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Pokémon Details'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PokemonDetailBloc>().add(
                              LoadPokemonDetail(pokemonId),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PokemonDetailLoaded) {
            return _buildDetailView(context, state.pokemon);
          }

          return const Scaffold(
            body: SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, Pokemon pokemon) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (pokemon.isOffline) const OfflineBanner(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: _buildSpriteCarousel(pokemon),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildContent(context, pokemon),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpriteCarousel(Pokemon pokemon) {
    final spriteList = pokemon.spriteUrls ?? [];
    
    // If no sprites available, fallback to single image
    if (spriteList.isEmpty) {
      return _buildImage(pokemon);
    }

    return _SpriteCarouselWithIndicator(spriteList: spriteList);
  }

  Widget _buildContent(BuildContext context, Pokemon pokemon) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdHeader(context, pokemon.id),
          const SizedBox(height: 16),
          if (pokemon.types.isNotEmpty) _buildTypesSection(context, pokemon.types),
          if (pokemon.stats != null && pokemon.stats!.isNotEmpty)
            _buildStatsSection(context, pokemon.stats!),
          if (pokemon.abilities != null && pokemon.abilities!.isNotEmpty)
            _buildAbilitiesSection(context, pokemon.abilities!),
        ],
      ),
    );
  }

  Widget _buildIdHeader(BuildContext context, int id) {
    return Text(
      '#$id',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.grey[600],
          ),
    );
  }

  Widget _buildTypesSection(BuildContext context, List<String> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Types',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: types.map((type) => Chip(label: Text(type))).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, List<PokemonStat> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...stats.map((stat) => _buildStatBar(context, stat)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAbilitiesSection(BuildContext context, List<String> abilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Abilities',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: abilities.map((ability) => Chip(label: Text(ability))).toList(),
        ),
      ],
    );
  }

  Widget _buildImage(Pokemon pokemon) {
    if (pokemon.cachedImagePath != null) {
      final file = File(pokemon.cachedImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      }
    }

    if (pokemon.imageUrl.isNotEmpty) {
      return Image.network(
        pokemon.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatBar(BuildContext context, PokemonStat stat) {
    // Clean up stat names like "special-attack" -> "Special Attack"
    final statName = stat.name
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  statName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${stat.value}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: stat.value / 255, // Base stat max is 255
            backgroundColor: Colors.grey[200],
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

/// Stateful widget for carousel with page indicator
class _SpriteCarouselWithIndicator extends StatefulWidget {
  const _SpriteCarouselWithIndicator({
    required this.spriteList,
  });

  final List<String> spriteList;

  @override
  State<_SpriteCarouselWithIndicator> createState() =>
      _SpriteCarouselWithIndicatorState();
}

class _SpriteCarouselWithIndicatorState
    extends State<_SpriteCarouselWithIndicator> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          items: widget.spriteList.map((url) {
            return Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            );
          }).toList(),
          options: CarouselOptions(
            height: 300,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            viewportFraction: 0.8,
            autoPlay: false,
            disableCenter: false,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Positioned(
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildPageIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.spriteList.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _carouselController.animateToPage(entry.key),
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == entry.key
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        );
      }).toList(),
    );
  }
}

