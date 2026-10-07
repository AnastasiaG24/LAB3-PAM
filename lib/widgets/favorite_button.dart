import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/favorites/favorites_cubit.dart';
import '../theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.id, this.size = 32});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.contains(id),
    );

    return Semantics(
      button: true,
      selected: isFavorite,
      label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: GestureDetector(
        onTap: () => context.read<FavoritesCubit>().toggle(id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: size * 0.55,
            color: isFavorite ? AppColors.danger : AppColors.grey700,
          ),
        ),
      ),
    );
  }
}
