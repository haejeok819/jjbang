import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComboFilterState {
  final String query;
  final Set<String> selectedBases;

  const ComboFilterState({
    this.query = '',
    this.selectedBases = const {},
  });

  ComboFilterState copyWith({
    String? query,
    Set<String>? selectedBases,
  }) {
    return ComboFilterState(
      query: query ?? this.query,
      selectedBases: selectedBases ?? this.selectedBases,
    );
  }
}

class ComboFilterNotifier extends StateNotifier<ComboFilterState> {
  ComboFilterNotifier() : super(const ComboFilterState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void toggleBase(String base) {
    final next = {...state.selectedBases};
    if (next.contains(base)) {
      next.remove(base);
    } else {
      next.add(base);
    }
    state = state.copyWith(selectedBases: next);
  }

  void clear() {
    state = const ComboFilterState();
  }
}

final comboFilterProvider =
StateNotifierProvider<ComboFilterNotifier, ComboFilterState>(
      (ref) => ComboFilterNotifier(),
);
