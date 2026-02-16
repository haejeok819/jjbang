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
        title: Text(combo.name),
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
          Text('${combo.base} · 난이도 ${combo.difficulty} · 도수 ${combo.alcoholLevel}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          if (combo.oneLiner.isNotEmpty) Text(combo.oneLiner),
          const SizedBox(height: 16),
          Text('재료', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...combo.ingredients.map((e) => Text('• $e')),
          const SizedBox(height: 16),
          Text('만드는 법', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...combo.steps.asMap().entries.map((e) => Text('${e.key + 1}. ${e.value}')),
          const SizedBox(height: 16),
          if (combo.tools.isNotEmpty) ...[
            Text('도구', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...combo.tools.map((e) => Text('• $e')),
            const SizedBox(height: 16),
          ],
          if (combo.warning.isNotEmpty) ...[
            Text('주의', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(combo.warning),
          ],
        ],
      ),
    );
  }
}
