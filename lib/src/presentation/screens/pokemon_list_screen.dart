import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pokemon.dart';
import '../bloc/pokemon_list/pokemon_list_bloc.dart';
import '../bloc/pokemon_list/pokemon_list_event.dart';
import '../bloc/pokemon_list/pokemon_list_state.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/offline_banner.dart';
import 'pokemon_detail_screen.dart';

/// Screen displaying paginated list of Pokémon
class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PokemonListBloc>().add(const LoadPokemonList());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PokemonListBloc>().add(const LoadMorePokemon());
    }

    // Update scroll-to-top button visibility
    if (_scrollController.hasClients) {
      final scrollPosition = _scrollController.position.pixels;
      final shouldShow = scrollPosition > 100;

      if (shouldShow != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShow;
        });
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Loading starts when the scroll position reaches 90% of the maximum scroll extent
    return currentScroll >= (maxScroll * 0.9);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      )
          .then((_) {
        // Hide button after scrolling to top
        if (mounted) {
          setState(() {
            _showScrollToTop = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _scrollToTop,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Pokémon Explorer'),
          ),
        ),
        elevation: 0,
        actions: _showScrollToTop
            ? [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _scrollToTop,
                  tooltip: 'Scroll to top',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<PokemonListBloc, PokemonListState>(
          buildWhen: (previous, current) {
            // Only rebuild if transitioning to/from loading state
            // or if the list length changes significantly (new page loaded)
            if (previous is PokemonListLoading &&
                current is PokemonListLoaded) {
              return true;
            }
            if (previous is PokemonListLoaded && current is PokemonListLoaded) {
              // Only rebuild if list length changed (pagination) or offline status changed
              return previous.pokemonList.length !=
                      current.pokemonList.length ||
                  previous.isOffline != current.isOffline ||
                  previous.isLoadingMore != current.isLoadingMore;
            }
            return previous.runtimeType != current.runtimeType;
          },
          builder: (context, state) {
            if (state is PokemonListLoading) {
              return _buildLoadingState();
            }

            if (state is PokemonListError) {
              return _buildErrorState(context, state.message);
            }

            if (state is PokemonListEmpty) {
              return _buildEmptyState(context);
            }

            if (state is PokemonListLoaded) {
              return _buildLoadedState(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
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
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PokemonListBloc>().add(const LoadPokemonList());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Pokémon found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, PokemonListLoaded state) {
    return Column(
      children: [
        if (state.isOffline) const OfflineBanner(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: GridView.builder(
              key: const PageStorageKey<String>('pokemon_grid'),
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.pokemonList.length,
              itemBuilder: (context, index) {
                return _buildPokemonCard(context, state.pokemonList[index]);
              },
            ),
          ),
        ),
        if (state.isLoadingMore) _buildLoadingMoreIndicator(context),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    context.read<PokemonListBloc>().add(const RefreshPokemonList());
    await Future.delayed(const Duration(seconds: 1));
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(
            radius: 12,
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more data...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonCard(BuildContext context, Pokemon pokemon) {
    return PokemonCard(
      pokemon: pokemon,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailScreen(
              pokemonId: pokemon.id,
            ),
          ),
        );
      },
    );
  }
}
