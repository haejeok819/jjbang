import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../combos/presentation/combo_detail_page.dart';
import '../state/favorites_sort_provider.dart';
import 'widgets/favorites_sort_chips.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sortedFavoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: Padding(
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
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final c = items[i];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text('${c.base.type} · ${c.alcoholLevel} · ${c.difficulty}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ComboDetailPage(comboId: c.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
