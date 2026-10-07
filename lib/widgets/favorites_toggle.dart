import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class FavoritesToggle extends StatelessWidget {
  const FavoritesToggle({
    super.key,
    required this.active,
    required this.onPressed,
  });

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: active,
      label: 'Show only favorites',
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.grey25,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: active ? null : Border.all(color: AppColors.grey100),
          ),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: active ? AppColors.white : AppColors.grey700,
          ),
        ),
      ),
    );
  }
}
