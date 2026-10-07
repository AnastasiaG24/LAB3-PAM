import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../cubits/gym/gym_cubit.dart';
import '../cubits/gym/gym_state.dart';
import '../data/app_assets.dart';
import '../data/fitness_repository.dart';
import '../models/gym.dart';
import '../models/gym_details.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/amenity_tile.dart';
import '../widgets/detail_hero.dart';
import '../widgets/primary_button.dart';
import '../widgets/state_views.dart';

class GymDetailScreen extends StatelessWidget {
  const GymDetailScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const GymDetailScreen());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GymCubit(context.read<FitnessRepository>())..load(),
      child: BlocBuilder<GymCubit, GymState>(
        builder: (context, state) => switch (state) {
          GymLoading() => const _StatusScaffold(child: LoadingView()),
          GymError(:final message) => _StatusScaffold(
            child: ErrorView(
              message: message,
              onRetry: context.read<GymCubit>().load,
            ),
          ),
          GymSuccess(:final details) => _GymDetailView(details: details),
        },
      ),
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        leading: const BackButton(color: AppColors.grey900),
      ),
      body: child,
    );
  }
}

class _GymDetailView extends StatelessWidget {
  const _GymDetailView({required this.details});

  final GymDetails details;

  @override
  Widget build(BuildContext context) {
    final gym = details.gym;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DetailHero(
                  imageUrl: gym.heroImageUrl,
                  trailing: SvgPicture.asset(
                    AppIcons.dotsVertical,
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: _Summary(gym: gym),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Text(
                    gym.description,
                    style: AppTextStyles.bodySmallRegular,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: _Amenities(gym: gym),
                ),
                const SizedBox(height: 140),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _BottomBar(details: details),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.gym});

  final Gym gym;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(AppIcons.star, width: 16, height: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${gym.rating} ',
                        style: AppTextStyles.bodySmallSemibold,
                      ),
                      TextSpan(
                        text: '(${_formatCount(gym.reviewCount)} reviews)',
                        style: AppTextStyles.bodySmallRegular,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(gym.name, style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text(gym.location, style: AppTextStyles.bodySmallRegular),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _Amenities extends StatelessWidget {
  const _Amenities({required this.gym});

  final Gym gym;

  @override
  Widget build(BuildContext context) {
    if (gym.amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities', style: AppTextStyles.bodyLargeSemibold),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: gym.amenities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 52,
          ),
          itemBuilder: (context, index) =>
              AmenityTile(amenity: gym.amenities[index]),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.details});

  final GymDetails details;

  @override
  Widget build(BuildContext context) {
    final pricing = details.gym.pricing;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, -10),
            blurRadius: 50,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 16, 25, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: AppTextStyles.bodySmallMedium),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${pricing.amountLabel} ',
                            style: AppTextStyles.h6,
                          ),
                          TextSpan(
                            text: pricing.periodLabel,
                            style: AppTextStyles.bodySmallMedium,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: details.reserveLabel,
                  onPressed: details.reserveEnabled
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${details.gym.name} reserved'),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
