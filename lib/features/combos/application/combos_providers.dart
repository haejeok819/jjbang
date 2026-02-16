import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/combo.dart';
import '../data/combo_repository.dart';
import '../data/combo_repository_local.dart';

final comboRepositoryProvider = Provider<ComboRepository>((ref) {
  return LocalComboRepository();
});

final combosProvider = FutureProvider<List<Combo>>((ref) async {
  final repo = ref.watch(comboRepositoryProvider);
  return repo.getCombos();
});

final comboByIdProvider = Provider.family<Combo?, String>((ref, id) {
  final combosAsync = ref.watch(combosProvider);
  return combosAsync.maybeWhen(
    data: (items) {
      for (final c in items) {
        if (c.id == id) return c;
      }
      return null;
    },
    orElse: () => null,
  );
});

final combosSearchOpenProvider = StateProvider.autoDispose<bool>((ref) => false);
