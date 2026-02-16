import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/combos_providers.dart';
import '../../favorites/state/favorites_notifier.dart';
import 'widgets/ratio_bar.dart';

class ComboDetailDialog extends ConsumerWidget {
  final String comboId;
  const ComboDetailDialog({super.key, required this.comboId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combo = ref.watch(comboByIdProvider(comboId));
    final favIds = ref.watch(favoritesIdsProvider);
    final isFav = favIds.contains(comboId);

    if (combo == null) {
      return const SizedBox(
        width: 520,
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 560,
        maxHeight: 720,
      ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 22,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(

            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 0,
                  titleSpacing: 16,
                  title: Text(
                    combo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                      onPressed: () => ref
                          .read(favoritesNotifierProvider.notifier)
                          .toggle(comboId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 6),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: const Divider(height: 1),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          '${combo.base.type} (${combo.base.ratio}) · 도수 ${combo.alcoholLevel} · 난이도 ${combo.difficulty}',
                        ),
                        const SizedBox(height: 12),
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
                            ...combo.mixers.map(
                                  (m) => RatioItem(label: m.name, ratioText: m.ratio),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('재료', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...combo.mixers.map((m) => Text('• ${m.name} ${m.ratio}')),
                        const SizedBox(height: 16),
                        Text('만드는 법', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...combo.steps.asMap().entries.map(
                              (e) => Text('${e.key + 1}. ${e.value}'),
                        ),
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
                  ),
                ),
              ],
            ),

          ),
        ),

    );
  }
}
