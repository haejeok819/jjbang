import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/combo_filter_state.dart';

class ComboFilterChips extends ConsumerWidget {
  const ComboFilterChips({super.key});

  static const bases = [
    '소주', '맥주', '막걸리', '고량주', '위스키', '사이다', '콜라', '토닉'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(comboFilterProvider).selectedBases;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final base in bases) ...[
            FilterChip(
              label: Text(base),
              selected: selected.contains(base),
              onSelected: (_) =>
                  ref.read(comboFilterProvider.notifier).toggleBase(base),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
