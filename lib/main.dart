import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/favorites/favorites_cubit.dart';
import 'data/app_assets.dart';
import 'data/fitness_repository.dart';
import 'data/json_fitness_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

const _maxContentWidth = 520.0;

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    FitnessApp(
      repository: JsonFitnessRepository(
        assetPath: const String.fromEnvironment(
          'DATA_ASSET',
          defaultValue: AppData.fitness,
        ),
      ),
    ),
  );
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key, required this.repository});

  final FitnessRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FitnessRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (_) => FavoritesCubit(),
        child: MaterialApp(
          title: 'Fitness Lab 3',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          builder: (context, child) => ColoredBox(
            color: AppColors.grey25,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: child,
              ),
            ),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
