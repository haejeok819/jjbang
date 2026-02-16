import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../combos/application/combo_filter_state.dart';
import '../../combos/application/combos_providers.dart';
import '../../combos/domain/combo.dart';
import 'favorites_notifier.dart';

enum FavoritesSort {
  added('최근순'),
  popularity('인기순'),
  alcohol('도수 높은순'),
  alcoholLow('도수 낮은순'),
  difficulty('난이도순');

  final String label;
  const FavoritesSort(this.label);
}

final favoritesSortProvider =
    StateProvider.autoDispose<FavoritesSort>((ref) => FavoritesSort.added);

final sortedFavoritesProvider = FutureProvider.autoDispose<List<Combo>>((ref) async {
  final all = await ref.watch(combosProvider.future);
  final favIds = ref.watch(favoritesIdsProvider);
  final selectedBases = ref.watch(selectedBasesProvider);

  final favorites = all.where((c) {
    final isFavorite = favIds.contains(c.id);
    final basePass = selectedBases.isEmpty ||
        selectedBases.contains(c.base.type) ||
        c.mixers.any((m) => selectedBases.contains(m.name));
    return isFavorite && basePass;
  }).toList();

  final sort = ref.watch(favoritesSortProvider);

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

  favorites.sort((a, b) {
    switch (sort) {
      case FavoritesSort.added:
        return 0;
      case FavoritesSort.popularity:
        return b.popularity.compareTo(a.popularity);
      case FavoritesSort.alcohol:
        return alcoholRank(b.alcoholLevel).compareTo(alcoholRank(a.alcoholLevel));
      case FavoritesSort.alcoholLow:
        return alcoholRank(a.alcoholLevel).compareTo(alcoholRank(b.alcoholLevel));
      case FavoritesSort.difficulty:
        return difficultyRank(b.difficulty).compareTo(difficultyRank(a.difficulty));
    }
  });

  if (sort == FavoritesSort.added) {
    final idx = <String, int>{};
    var i = 0;
    for (final id in favIds) {
      idx[id] = i++;
    }
    favorites.sort((a, b) => (idx[a.id] ?? 999999).compareTo(idx[b.id] ?? 999999));
  }

  return favorites;
});
