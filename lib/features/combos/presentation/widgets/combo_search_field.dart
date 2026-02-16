import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/combos_providers.dart';

class ComboSearchField extends ConsumerStatefulWidget {
  const ComboSearchField({super.key});

  @override
  ConsumerState<ComboSearchField> createState() => _ComboSearchFieldState();
}

class _ComboSearchFieldState extends ConsumerState<ComboSearchField> {
  final _c = TextEditingController();
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _t?.cancel();
    _t = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: '조합 이름/베이스/태그 검색',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
