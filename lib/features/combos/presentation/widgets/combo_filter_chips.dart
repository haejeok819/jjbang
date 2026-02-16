import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/combos_providers.dart';

class ComboFilterChips extends ConsumerWidget {
  const ComboFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedChipsProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ComboChip.values.map((chip) {
          final isSel = selected.contains(chip);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(chip.label),
              selected: isSel,
              onSelected: (_) {
                final next = {...selected};
                if (isSel) {
                  next.remove(chip);
                } else {
                  next.add(chip);
                }
                ref.read(selectedChipsProvider.notifier).state = next;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
