import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum PrimaryButtonSize { xSmall, large }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PrimaryButtonSize.large,
  });

  final String label;
  final VoidCallback? onPressed;
  final PrimaryButtonSize size;

  bool get _isSmall => size == PrimaryButtonSize.xSmall;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null ? AppColors.grey200 : AppColors.primary,
      borderRadius: BorderRadius.circular(_isSmall ? 6 : 12),
      elevation: 0,
      child: Semantics(
        container: true,
        button: true,
        enabled: onPressed != null,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_isSmall ? 6 : 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: _isSmall ? 32 : 52,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _isSmall
                          ? AppTextStyles.bodyXSmallSemibold.copyWith(
                              color: AppColors.white,
                            )
                          : AppTextStyles.bodyMediumSemibold.copyWith(
                              color: AppColors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
