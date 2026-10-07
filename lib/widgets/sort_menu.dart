import 'package:flutter/material.dart';

import '../models/program_sort.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SortMenu extends StatelessWidget {
  const SortMenu({super.key, required this.value, required this.onSelected});

  final ProgramSort value;
  final ValueChanged<ProgramSort> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = value != ProgramSort.none;

    return PopupMenuButton<ProgramSort>(
      tooltip: 'Sort programs',
      initialValue: value,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final option in ProgramSort.values)
          CheckedPopupMenuItem<ProgramSort>(
            value: option,
            checked: option == value,
            child: Text(option.label, style: AppTextStyles.bodySmallMedium),
          ),
      ],
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.grey25,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: active ? null : Border.all(color: AppColors.grey100),
        ),
        child: Icon(
          Icons.sort_rounded,
          color: active ? AppColors.white : AppColors.grey700,
        ),
      ),
    );
  }
}
