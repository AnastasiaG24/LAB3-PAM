import 'package:flutter/material.dart';

import '../data/app_assets.dart';
import '../models/featured_plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_network_image.dart';
import 'icon_metric.dart';
import 'primary_button.dart';

class FeaturedPlanCard extends StatelessWidget {
  const FeaturedPlanCard({
    super.key,
    required this.plan,
    required this.onStart,
  });

  final FeaturedPlan plan;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 296,
      height: 144,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: plan.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xB3000000), Color(0x1A000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        plan.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconMetric(
                            iconPath: AppIcons.barbell,
                            label: plan.duration,
                            iconSize: 16,
                            gap: 4,
                            style: AppTextStyles.bodyXSmallRegular.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plan.frequency,
                            style: AppTextStyles.bodyXSmallRegular.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PrimaryButton(
                    label: plan.actionLabel,
                    size: PrimaryButtonSize.xSmall,
                    onPressed: onStart,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
