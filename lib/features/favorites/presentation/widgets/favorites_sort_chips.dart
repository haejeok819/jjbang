import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/favorites_sort_provider.dart';

class FavoritesSortChips extends ConsumerWidget {
  const FavoritesSortChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(favoritesSortProvider);

    return SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (final s in FavoritesSort.values) ...[
              ChoiceChip(
                label: Text(s.label),
                selected: s == current,
                onSelected: (_) => ref.read(favoritesSortProvider.notifier).state = s,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
