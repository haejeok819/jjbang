import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/combo.dart';
import '../data/combo_repository.dart';
import '../../favorites/state/favorites_notifier.dart';

enum ComboChip {
  soju('소주'),
  beer('맥주'),
  makgeolli('막걸리'),
  kaoliang('고량주'),
  whisky('위스키'),
  cider('사이다'),
  cola('콜라'),
  tonic('토닉');

  final String label;
  const ComboChip(this.label);
}

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final selectedChipsProvider =
StateProvider.autoDispose<Set<ComboChip>>((ref) => <ComboChip>{});

final combosProvider = FutureProvider<List<Combo>>((ref) async {
  final repo = ref.watch(comboRepositoryProvider);
  final items = await repo.getCombos();
  items.sort((a, b) => b.popularity.compareTo(a.popularity));
  return items;
});

final filteredCombosProvider = Provider<AsyncValue<List<Combo>>>((ref) {
  final q = ref.watch(searchQueryProvider).trim().toLowerCase();
  final chips = ref.watch(selectedChipsProvider);
  final combosAsync = ref.watch(combosProvider);

  return combosAsync.whenData((items) {
    bool chipPass(Combo c) {
      if (chips.isEmpty) return true;
      final tags = c.filterTags.map((e) => e.toLowerCase()).toSet();
      for (final ch in chips) {
        if (tags.contains(ch.label.toLowerCase())) return true;
      }
      return false;
    }

    bool queryPass(Combo c) {
      if (q.isEmpty) return true;
      final hay = [
        c.name,
        c.base,
        ...c.tasteTags,
        ...c.filterTags,
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }

    return items.where((c) => queryPass(c) && chipPass(c)).toList();
  });
});

final comboByIdProvider = Provider.family<Combo?, String>((ref, id) {
  final combosAsync = ref.watch(combosProvider);
  return combosAsync.maybeWhen(
    data: (items) => items.where((e) => e.id == id).cast<Combo?>().firstOrNull,
    orElse: () => null,
  );
});

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
