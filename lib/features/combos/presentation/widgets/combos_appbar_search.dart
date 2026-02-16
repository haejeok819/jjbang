import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/combo_filter_state.dart';
import '../../application/combos_providers.dart';

class CombosAppbarSearch extends ConsumerWidget {
  const CombosAppbarSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(combosSearchOpenProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: open
          ? Padding(
        key: const ValueKey('open'),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: TextField(
          autofocus: true,
          onChanged: (v) =>
              ref.read(comboFilterProvider.notifier).setQuery(v),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '검색',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () {
                ref.read(comboFilterProvider.notifier).setQuery('');
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      )
          : const SizedBox(
        key: ValueKey('closed'),
        height: 0,
      ),
    );
  }
}
