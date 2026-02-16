import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComboFilterState {
  final String query;

  const ComboFilterState({
    this.query = '',
  });

  ComboFilterState copyWith({
    String? query,
  }) {
    return ComboFilterState(
      query: query ?? this.query,
    );
  }
}

class ComboFilterNotifier extends StateNotifier<ComboFilterState> {
  ComboFilterNotifier() : super(const ComboFilterState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void clear() {
    state = const ComboFilterState();
  }
}

final comboFilterProvider =
    StateNotifierProvider<ComboFilterNotifier, ComboFilterState>(
      (ref) => ComboFilterNotifier(),
    );

final selectedBasesProvider = StateProvider<Set<String>>((ref) => <String>{});
