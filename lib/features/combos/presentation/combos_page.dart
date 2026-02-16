import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/combos_providers.dart';
import 'widgets/combo_search_field.dart';
import 'widgets/combo_filter_chips.dart';
import 'combo_detail_page.dart';
import '../../favorites/state/favorites_notifier.dart';

class CombosPage extends ConsumerWidget {
  const CombosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredCombosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('조합')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ComboSearchField(),
            const SizedBox(height: 12),
            const ComboFilterChips(),
            const SizedBox(height: 12),
            Expanded(
              child: filteredAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('검색 결과가 없어요'));
                  }
                  final fav = ref.watch(favoritesIdsProvider);
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final c = items[i];
                      final id = c.id ?? '';
                      final isFav = fav.contains(id);
                      return Card(
                        child: ListTile(
                          title: Text(c.name ?? ''),
                          subtitle: Text(c.base.toString() ?? ''),
                          trailing: IconButton(
                            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                            onPressed: id.isEmpty
                                ? null
                                : () => ref.read(favoritesNotifierProvider.notifier).toggle(id),
                          ),
                          onTap: id.isEmpty
                              ? null
                              : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ComboDetailPage(comboId: id),
                              ),
                            );
                          },
                        ),
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
