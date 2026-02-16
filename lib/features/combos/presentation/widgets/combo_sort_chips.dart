import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/filtered_combo_provider.dart';

class ComboSortChips extends ConsumerWidget {
  const ComboSortChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(comboSortProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final s in ComboSort.values) ...[
            ChoiceChip(
              label: Text(s.label),
              selected: s == current,
              onSelected: (_) =>
              ref.read(comboSortProvider.notifier).state = s,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
