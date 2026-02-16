import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/combo_filter_state.dart';
import '../../application/combos_providers.dart';

class CombosAppbarSearch extends ConsumerStatefulWidget {
  const CombosAppbarSearch({super.key});

  @override
  ConsumerState<CombosAppbarSearch> createState() =>
      _CombosAppbarSearchState();
}

class _CombosAppbarSearchState
    extends ConsumerState<CombosAppbarSearch> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          controller: _controller,
          autofocus: true,
          onChanged: (v) =>
              ref.read(comboFilterProvider.notifier).setQuery(v),
          onSubmitted: (_) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '조합 이름 또는 베이스 술/음료를 검색해보세요 !',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () {
                _controller.clear(); // 👈 실제 텍스트 지움
                ref
                    .read(comboFilterProvider.notifier)
                    .setQuery('');
                FocusManager.instance.primaryFocus?.unfocus();
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
