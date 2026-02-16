import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/combo_filter_state.dart';
import '../application/filtered_combo_provider.dart';
import '../application/combos_providers.dart' as p;

import 'widgets/combo_filter_chips.dart';
import 'widgets/combo_sort_chips.dart';
import 'widgets/combos_appbar_search.dart';

class CombosPage extends ConsumerWidget {
  const CombosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(filteredComboProvider);
    final filter = ref.watch(comboFilterProvider);
    final sort = ref.watch(comboSortProvider);
    final keySig = '${filter.query}|${filter.selectedBases.join(",")}|$sort';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          height: 44,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final cur = ref.read(p.combosSearchOpenProvider);
              ref.read(p.combosSearchOpenProvider.notifier).state = !cur;
              if (cur) {
                ref.read(comboFilterProvider.notifier).setQuery('');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const CombosAppbarSearch(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                SizedBox(height: 8),
                ComboFilterChips(),
                SizedBox(height: 12),
                ComboSortChips(),
                SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: async.when(
                loading: () => const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  key: const ValueKey('error'),
                  child: Text('$e'),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      key: ValueKey('empty'),
                      child: Text('조건에 맞는 조합이 없어요'),
                    );
                  }

                  return ListView.builder(
                    key: ValueKey(keySig),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final c = items[i];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.base.type} · ${c.alcoholLevel} · ${c.difficulty}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
