import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/core/di/injection_container.dart' as di;
import 'src/presentation/screens/pokemon_list_screen.dart';
import 'src/presentation/bloc/pokemon_list/pokemon_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.setupDependencyInjection();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider<PokemonListBloc>(
        create: (context) => di.getIt<PokemonListBloc>(),
        child: const PokemonListScreen(),
      ),
    );
  }
}
