import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/combos_providers.dart';
import '../../favorites/state/favorites_notifier.dart';

class ComboDetailPage extends ConsumerWidget {
  final String comboId;
  const ComboDetailPage({super.key, required this.comboId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combo = ref.watch(comboByIdProvider(comboId));
    final favIds = ref.watch(favoritesIdsProvider);
    final isFav = favIds.contains(comboId);

    if (combo == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(combo.name ?? ''),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () => ref.read(favoritesNotifierProvider.notifier).toggle(comboId),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(combo.base.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('난이도: ${combo.difficulty ?? '-'}'),
          const SizedBox(height: 8),
          Text('도수: ${combo.alcoholLevel?.toString() ?? '-'}'),
          const SizedBox(height: 8),
          Text('인기: ${combo.popularity?.toString() ?? '-'}'),
        ],
      ),
    );
  }
}
