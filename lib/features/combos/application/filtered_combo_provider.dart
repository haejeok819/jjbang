import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/combo.dart';
import '../data/combo_repository.dart';
import '../data/combo_repository_local.dart';
import 'combo_filter_state.dart';
import 'debounced_query_provider.dart';

final filteredComboProvider = FutureProvider<List<Combo>>((ref) async {
  final combos = await ref.watch(comboListProvider.future);

  final filter = ref.watch(comboFilterProvider);
  final debouncedQuery = ref.watch(debouncedQueryProvider).value ?? '';

  final q = debouncedQuery.trim().toLowerCase();
  final selected = filter.selectedBases;

  final result = combos.where((c) {
    final matchesQuery = q.isEmpty ||
        c.name.toLowerCase().contains(q) ||
        c.base.toLowerCase().contains(q) ||
        c.tasteTags.any((t) => t.toLowerCase().contains(q));

    final matchesBase = selected.isEmpty || selected.contains(c.base);

    return matchesQuery && matchesBase;
  }).toList();

  return result;
});
