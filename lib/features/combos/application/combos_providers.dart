import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/combo_repository_local.dart';
import '../domain/combo.dart';

final comboRepositoryProvider = Provider<ComboRepositoryLocal>((ref) {
  return ComboRepositoryLocal();
});

final combosProvider = FutureProvider<List<Combo>>((ref) async {
  final repo = ref.watch(comboRepositoryProvider);
  final list = await repo.load();

  final sorted = List<Combo>.from(list)
    ..sort((a, b) => b.popularity.compareTo(a.popularity));

  return sorted;
});
