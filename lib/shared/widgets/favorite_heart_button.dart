import 'package:flutter/material.dart';

class FavoriteHeartButton extends StatelessWidget {
  const FavoriteHeartButton({
    super.key,
    required this.isFav,
    required this.onPressed,
  });

  final bool isFav;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(isFav),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        final peak = 1 - (2 * t - 1).abs();
        final scale = 1 + peak * 0.2;

        return AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 120),
          child: child,
        );
      },
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? const Color(0xFFFF6B6B) : null,
        ),
      ),
    );
  }
}
