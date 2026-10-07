import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/favorites/favorites_cubit.dart';
import '../data/app_assets.dart';
import '../models/workout_program.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/detail_hero.dart';
import '../widgets/favorite_button.dart';
import '../widgets/icon_metric.dart';
import '../widgets/primary_button.dart';
import '../widgets/program_card.dart';

class ProgramDetailsScreen extends StatelessWidget {
  const ProgramDetailsScreen({super.key, required this.program});

  static Route<void> route(WorkoutProgram program) => MaterialPageRoute<void>(
    builder: (_) => ProgramDetailsScreen(program: program),
  );

  final WorkoutProgram program;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            DetailHero(
              imageUrl: program.imageUrl,
              trailing: FavoriteButton(id: program.id, size: 48),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(program.title, style: AppTextStyles.h4),
                      ),
                      if (program.isPro) ...[
                        const SizedBox(width: 12),
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: ProBadge(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          iconPath: AppIcons.flame,
                          value: '${program.calories} kcl',
                          label: 'Calories',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatTile(
                          iconPath: AppIcons.clock,
                          value: '${program.durationMinutes} min',
                          label: 'Duration',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _FavoriteAction(programId: program.id),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.iconPath,
    required this.value,
    required this.label,
  });

  final String iconPath;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey25,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconMetric(
            iconPath: iconPath,
            label: label,
            iconSize: 16,
            gap: 6,
            iconColor: AppColors.primary,
            style: AppTextStyles.bodySmallRegular,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h6,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.contains(programId),
    );

    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: () => context.read<FavoritesCubit>().toggle(programId),
      ),
    );
  }
}
