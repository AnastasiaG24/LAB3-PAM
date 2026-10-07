import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_network_image.dart';

class DetailHero extends StatelessWidget {
  const DetailHero({
    super.key,
    required this.imageUrl,
    this.trailing,
    this.height = 350,
  });

  final String imageUrl;
  final Widget? trailing;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(url: imageUrl),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const RoundBackButton(), ?trailing],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundBackButton extends StatelessWidget {
  const RoundBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: SvgPicture.asset(AppIcons.arrowLeft, width: 24, height: 24),
          ),
        ),
      ),
    );
  }
}
