import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../cubits/favorites/favorites_cubit.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/home/home_state.dart';
import '../data/app_assets.dart';
import '../data/fitness_repository.dart';
import '../models/featured_plan.dart';
import '../models/home_header.dart';
import '../models/workout_program.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/category_chip.dart';
import '../widgets/challenge_card.dart';
import '../widgets/favorites_toggle.dart';
import '../widgets/featured_plan_card.dart';
import '../widgets/program_card.dart';
import '../widgets/search_field.dart';
import '../widgets/section_header.dart';
import '../widgets/sort_menu.dart';
import '../widgets/state_views.dart';
import 'gym_detail_screen.dart';
import 'program_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        context.read<FitnessRepository>(),
        favoriteIds: context.read<FavoritesCubit>().state,
      )..load(),
      child: BlocListener<FavoritesCubit, Set<String>>(
        listener: (context, favoriteIds) =>
            context.read<HomeCubit>().updateFavorites(favoriteIds),
        child: const HomeView(),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => switch (state) {
            HomeLoading() => const LoadingView(),
            HomeError(:final message) => ErrorView(
              message: message,
              onRetry: context.read<HomeCubit>().load,
            ),
            HomeReady() => _HomeContent(state: state),
          },
        ),
      ),
    );
  }
}

const _horizontalPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.screenPadding,
);

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeReady state;

  static const refreshFailedMessage = 'Could not refresh. Showing saved data.';

  Future<void> _refresh(BuildContext context, HomeCubit cubit) async {
    final refreshed = await cubit.refresh();
    if (refreshed || !context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text(refreshFailedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final data = state.data;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _refresh(context, cubit),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        children: [
          Padding(
            padding: _horizontalPadding,
            child: _Greeting(header: data.header),
          ),
          const SizedBox(height: 29),
          Padding(
            padding: _horizontalPadding,
            child: ChallengeCard(
              label: data.challenge.title,
              title: data.challenge.activity,
              completed: data.challenge.completed,
              total: data.challenge.total,
            ),
          ),
          if (data.featuredPlans.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: _horizontalPadding,
              child: SectionHeader(title: 'Featured Plan', onSeeAll: () {}),
            ),
            const SizedBox(height: 16),
            _FeaturedPlans(plans: data.featuredPlans),
          ],
          const SizedBox(height: 24),
          const Padding(
            padding: _horizontalPadding,
            child: SectionHeader(title: 'Workout Programs'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: _horizontalPadding,
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    value: state.query.search,
                    onChanged: cubit.search,
                  ),
                ),
                const SizedBox(width: 12),
                FavoritesToggle(
                  active: state.query.favoritesOnly,
                  onPressed: cubit.toggleFavoritesOnly,
                ),
                const SizedBox(width: 8),
                SortMenu(value: state.query.sort, onSelected: cubit.changeSort),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: _horizontalPadding,
              itemCount: data.filters.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.chipGap),
              itemBuilder: (context, index) {
                final filter = data.filters[index];
                return CategoryChip(
                  label: filter.name,
                  selected: filter.id == state.query.filterId,
                  onTap: () => cubit.selectFilter(filter.id),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: _horizontalPadding,
            child: switch (state) {
              HomeSuccess(:final programs) => _ProgramGrid(programs: programs),
              HomeEmpty(:final query) when query.favoritesOnly => EmptyView(
                message:
                    'No favorite programs here. Tap the heart on a program '
                    'to add it.',
                actionLabel: 'Reset filters',
                onAction: cubit.resetQuery,
              ),
              HomeEmpty(:final isQueryActive) when isQueryActive => EmptyView(
                message: 'No workout programs match your search or filter.',
                actionLabel: 'Reset filters',
                onAction: cubit.resetQuery,
              ),
              HomeEmpty() => const EmptyView(
                message: 'There are no workout programs yet.',
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.header});

  final HomeHeader header;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(header.date, style: AppTextStyles.bodySmallRegular),
              const SizedBox(height: 4),
              Text(header.greeting, style: AppTextStyles.h6),
            ],
          ),
        ),
        SvgPicture.asset(AppIcons.bell, width: 48, height: 48),
      ],
    );
  }
}

class _FeaturedPlans extends StatelessWidget {
  const _FeaturedPlans({required this.plans});

  final List<FeaturedPlan> plans;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 144,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: _horizontalPadding,
        itemCount: plans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) => FeaturedPlanCard(
          plan: plans[index],
          onStart: () => Navigator.of(context).push(GymDetailScreen.route()),
        ),
      ),
    );
  }
}

class _ProgramGrid extends StatelessWidget {
  const _ProgramGrid({required this.programs});

  final List<WorkoutProgram> programs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _buildGrid(
        context,
        columns: constraints.maxWidth < _twoColumnMinWidth ? 1 : 2,
      ),
    );
  }

  static const _twoColumnMinWidth = 300.0;

  Widget _buildGrid(BuildContext context, {required int columns}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: programs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 184,
      ),
      itemBuilder: (context, index) {
        final program = programs[index];
        return ProgramCard(
          key: ValueKey(program.id),
          program: program,
          onTap: () =>
              Navigator.of(context).push(ProgramDetailsScreen.route(program)),
        );
      },
    );
  }
}
