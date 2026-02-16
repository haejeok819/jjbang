import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/combo.dart';
import '../application/combos_providers.dart';
import 'combo_filter_state.dart';
import 'debounced_query_provider.dart';

enum ComboSort {
  added('최근순'),
  popularity('인기순'),
  alcohol('도수 높은순'),
  alcoholLow('도수 낮은순'),
  difficulty('난이도순');

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
  final selectedBases = ref.watch(selectedBasesProvider);

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
    if (selectedBases.contains(c.base.type)) return true;

    return c.mixers.any((m) => selectedBases.contains(m.name));
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

  final addedOrder = <String, int>{
    for (var i = 0; i < items.length; i++) items[i].id: i,
  };

  filtered.sort((a, b) {
    switch (sort) {
      case ComboSort.added:
        return (addedOrder[a.id] ?? 999999).compareTo(addedOrder[b.id] ?? 999999);
      case ComboSort.popularity:
        return b.popularity.compareTo(a.popularity);
      case ComboSort.alcohol:
        return alcoholRank(b.alcoholLevel).compareTo(alcoholRank(a.alcoholLevel));
      case ComboSort.alcoholLow:
        return alcoholRank(a.alcoholLevel).compareTo(alcoholRank(b.alcoholLevel));
      case ComboSort.difficulty:
        return difficultyRank(b.difficulty).compareTo(difficultyRank(a.difficulty));
    }
  });

  return filtered;
});
