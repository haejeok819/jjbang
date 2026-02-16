import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/combo_filter_state.dart';

class ComboFilterChips extends ConsumerWidget {
  const ComboFilterChips({super.key});

  static const bases = [
    '소주',
    '맥주',
    '막걸리',
    '고량주',
    '위스키',
    '사이다',
    '콜라',
    '토닉',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBasesProvider);

    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        primary: false,
        dragStartBehavior: DragStartBehavior.down,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            for (final base in bases) ...[
              FilterChip(
                label: Text(base),
                selected: selected.contains(base),
                onSelected: (_) {
                  final next = {...selected};
                  if (next.contains(base)) {
                    next.remove(base);
                  } else {
                    next.add(base);
                  }
                  ref.read(selectedBasesProvider.notifier).state = next;
                },
              ),
              const SizedBox(width: 8),
            ],
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
