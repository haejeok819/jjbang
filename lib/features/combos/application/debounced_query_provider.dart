import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'combo_filter_state.dart';

final debouncedQueryProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>();
  Timer? timer;

  void emit(String value) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 300), () {
      controller.add(value);
    });
  }

  final sub = ref.listen<ComboFilterState>(
    comboFilterProvider,
        (prev, next) => emit(next.query),
    fireImmediately: true,
  );

  ref.onDispose(() {
    sub.close();
    timer?.cancel();
    controller.close();
  });

  return controller.stream.distinct();
});
