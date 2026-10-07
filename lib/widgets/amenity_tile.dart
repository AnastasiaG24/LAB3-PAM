import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/amenity.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AmenityTile extends StatelessWidget {
  const AmenityTile({super.key, required this.amenity});

  final Amenity amenity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.grey25,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: [
          SvgPicture.network(
            amenity.iconUrl,
            width: 20,
            height: 20,
            placeholderBuilder: (_) => const SizedBox.square(dimension: 20),
            errorBuilder: (_, _, _) => const Icon(
              Icons.check_circle_outline_rounded,
              size: 20,
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              amenity.name,
              style: AppTextStyles.bodySmallRegular,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
