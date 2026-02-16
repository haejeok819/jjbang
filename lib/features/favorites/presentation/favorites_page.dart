import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jjbang/shared/widgets/favorite_heart_button.dart';
import 'package:jjbang/shared/widgets/pressable.dart';
import 'package:jjbang/shared/widgets/tag_chip.dart';

import '../../combos/presentation/combo_detail_dialog.dart';
import '../state/favorites_notifier.dart';
import '../state/favorites_sort_provider.dart';
import 'widgets/favorites_sort_chips.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sortedFavoritesProvider);

    void openCombo(String id) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'combo_detail',
        barrierColor: Colors.black.withOpacity(0.45),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return Center(
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ComboDetailDialog(comboId: id),
            ),
          );
        },
        transitionBuilder: (context, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
          final scale = Tween<double>(begin: 0.92, end: 1.0).animate(curved);
          final slide = Tween<double>(begin: 28.0, end: 0.0).animate(curved);

          return FadeTransition(
            opacity: fade,
            child: Transform.translate(
              offset: Offset(0, slide.value),
              child: Transform.scale(
                scale: scale.value,
                child: child,
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const FavoritesSortChips(),
          const SizedBox(height: 12),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('아직 즐겨찾기가 없어요'));
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = items[i];

                    return Pressable(
                      onTap: () => openCombo(c.id),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'NanumSquare',
                                      ),
                                    ),
                                  ),
                                  FavoriteHeartButton(
                                    isFav: true,
                                    onPressed: () => ref
                                        .read(favoritesNotifierProvider.notifier)
                                        .toggle(c.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  TagChip(label: c.base.type, type: TagType.base),
                                  TagChip(
                                    label: '도수 ${c.alcoholLevel}',
                                    type: TagType.alcohol,
                                  ),
                                  TagChip(
                                    label: '난이도 ${c.difficulty}',
                                    type: TagType.difficulty,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: c.taste
                                    .map((t) => TagChip(label: t, type: TagType.taste))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
