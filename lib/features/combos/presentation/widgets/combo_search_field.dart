import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/combo_filter_state.dart';

class ComboSearchField extends ConsumerWidget {
  const ComboSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (v) => ref.read(comboFilterProvider.notifier).setQuery(v),
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: '조합 이름 또는 베이스 술을 검색하세요',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
