import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/combos_providers.dart';

import '../../favorites/state/favorites_notifier.dart';
import 'widgets/ratio_bar.dart';

class ComboDetailPage extends ConsumerWidget {
  final String comboId;
  const ComboDetailPage({super.key, required this.comboId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combo = ref.watch(comboByIdProvider(comboId));
    final favIds = ref.watch(favoritesIdsProvider);
    final isFav = favIds.contains(comboId);

    if (combo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(combo.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () => ref
                .read(favoritesNotifierProvider.notifier)
                .toggle(comboId),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${combo.base.type} (${combo.base.ratio})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('난이도: ${combo.difficulty}'),
          const SizedBox(height: 6),
          Text('도수: ${combo.alcoholLevel}'),
          const SizedBox(height: 6),
          Text('인기도: ${combo.popularity}'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: combo.taste.map((t) => Chip(label: Text(t))).toList(),
          ),
          const SizedBox(height: 16),
          Text('비율', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RatioBar(
            items: [
              RatioItem(label: combo.base.type, ratioText: combo.base.ratio),
              ...combo.mixers.map((m) => RatioItem(label: m.name, ratioText: m.ratio)),
            ],
          ),

          Text('재료', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...combo.mixers.map((m) => Text('• ${m.name} ${m.ratio}')),
          const SizedBox(height: 16),
          Text('만드는 법', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...combo.steps.asMap().entries.map((e) => Text('${e.key + 1}. ${e.value}')),
          const SizedBox(height: 16),
          if (combo.tools.isNotEmpty) ...[
            Text('도구', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...combo.tools.map((t) => Text('• $t')),
            const SizedBox(height: 16),
          ],
          if (combo.oneLiner?.isNotEmpty == true) ...[
            Text('한 줄', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(combo.oneLiner!),
            const SizedBox(height: 16),
          ],
          if (combo.warning?.isNotEmpty == true) ...[
            Text('주의', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(combo.warning!),
          ],
        ],
      ),
    );
  }
}
