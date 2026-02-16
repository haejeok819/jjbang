import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/favorites_repository.dart';
import '../data/local_favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return LocalFavoritesRepository();
});

final favoritesNotifierProvider =
AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

final favoritesIdsProvider = Provider<Set<String>>((ref) {
  final async = ref.watch(favoritesNotifierProvider);
  return async.maybeWhen(data: (v) => v, orElse: () => <String>{});
});

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final repo = ref.read(favoritesRepositoryProvider);
    return repo.loadIds();
  }

  Future<void> toggle(String id) async {
    final repo = ref.read(favoritesRepositoryProvider);
    final cur = state.valueOrNull ?? <String>{};
    final next = {...cur};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = AsyncData(next);
    await repo.saveIds(next);
  }
}
