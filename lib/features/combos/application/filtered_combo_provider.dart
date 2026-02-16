import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/combo.dart';
import '../application/combos_providers.dart';
import 'combo_filter_state.dart';
import 'debounced_query_provider.dart';

enum ComboSort {
  popularity('인기'),
  alcohol('도수'),
  difficulty('난이도');

  final String label;
  const ComboSort(this.label);
}

final comboSortProvider =
StateProvider.autoDispose<ComboSort>((ref) => ComboSort.popularity);

final filteredComboProvider = FutureProvider.autoDispose<List<Combo>>((ref) async {
  final items = await ref.watch(combosProvider.future);

  final filter = ref.watch(comboFilterProvider);
  final sort = ref.watch(comboSortProvider);
  final debounced = ref.watch(debouncedQueryProvider).value ?? filter.query;

  final q = debounced.trim().toLowerCase();
  final selectedBases = filter.selectedBases;

  bool queryPass(Combo c) {
    if (q.isEmpty) return true;

    final hay = <String>[
      c.name,
      c.base.type,
      ...c.taste,
      ...c.keywords,
      ...c.extraTags,
    ].join(' ').toLowerCase();

    return hay.contains(q);
  }

  bool chipPass(Combo c) {
    if (selectedBases.isEmpty) return true;
    return selectedBases.contains(c.base.type);
  }

  int alcoholRank(String v) {
    switch (v) {
      case '낮음':
        return 0;
      case '중간':
        return 1;
      case '높음':
        return 2;
      default:
        return 999;
    }
  }

  int difficultyRank(String v) {
    switch (v) {
      case '쉬움':
        return 0;
      case '보통':
        return 1;
      case '어려움':
        return 2;
      default:
        return 999;
    }
  }

  final filtered = items.where((c) => queryPass(c) && chipPass(c)).toList();

  filtered.sort((a, b) {
    switch (sort) {
      case ComboSort.popularity:
        return b.popularity.compareTo(a.popularity);
      case ComboSort.alcohol:
        return alcoholRank(b.alcoholLevel).compareTo(alcoholRank(a.alcoholLevel));
      case ComboSort.difficulty:
        return difficultyRank(b.difficulty).compareTo(difficultyRank(a.difficulty));
    }
  });

  return filtered;
});
