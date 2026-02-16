import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../combos/presentation/combo_detail_page.dart';
import '../state/favorites_notifier.dart';
import '../state/favorites_sort_provider.dart';
import 'widgets/favorites_sort_chips.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sortedFavoritesProvider);

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
                  return const Center(
                    child: Text(
                      '아직 즐겨찾기가 없어요',
                      style: TextStyle(fontFamily: 'NanumSquare', fontWeight: FontWeight.w700),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = items[i];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComboDetailPage(comboId: c.id),
                            ),
                          );
                        },
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
                                  IconButton(
                                    onPressed: () => ref
                                        .read(favoritesNotifierProvider.notifier)
                                        .toggle(c.id),
                                    icon: const Icon(Icons.favorite),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _Pill(text: c.base.type),
                                  _Pill(text: '도수 ${c.alcoholLevel}'),
                                  _Pill(text: '난이도 ${c.difficulty}'),
                                ],
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

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'NanumSquare',
        ),
      ),
    );
  }
}
