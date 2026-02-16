import 'package:flutter/material.dart';

class FavoritePopButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;

  const FavoritePopButton({
    super.key,
    required this.isFav,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: isFav ? 1.15 : 1.0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: IconButton(
        onPressed: onTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(isFav),
          ),
        ),
      ),
    );
  }
}
