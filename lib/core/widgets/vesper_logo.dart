import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Vesper logo from assets/images/vesper_logo.png.
/// If the image is missing, the name is shown instead so the screen never breaks.
class VesperLogo extends StatelessWidget {
  const VesperLogo({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/vesper_logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Text(
        'Vesper',
        style: TextStyle(color: AppColors.navy, fontSize: height * 0.6, fontWeight: FontWeight.w700),
      ),
    );
  }
}
