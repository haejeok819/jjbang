import 'package:flutter/material.dart';

enum TagType {
  base,
  alcohol,
  difficulty,
  taste,
  extra,
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.type,
  });

  final String label;
  final TagType type;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: style.foreground,
        ),
      ),
    );
  }

  _TagColors _styleFor(TagType type) {
    switch (type) {
      case TagType.base:
        return const _TagColors(
          background: Color(0xFFF2F4F8),
          border: Color(0xFFDDE3EA),
          foreground: Color(0xFF344054),
        );
      case TagType.alcohol:
        return const _TagColors(
          background: Color(0xFFFFF1F3),
          border: Color(0xFFFFD4DB),
          foreground: Color(0xFFB42318),
        );
      case TagType.difficulty:
        return const _TagColors(
          background: Color(0xFFEEF4FF),
          border: Color(0xFFD3E0FF),
          foreground: Color(0xFF1849A9),
        );
      case TagType.taste:
        return const _TagColors(
          background: Color(0xFFE9FBF5),
          border: Color(0xFFC9F2E5),
          foreground: Color(0xFF0F766E),
        );
      case TagType.extra:
        return const _TagColors(
          background: Color(0xFFF8F0FF),
          border: Color(0xFFE7D6FF),
          foreground: Color(0xFF6941C6),
        );
    }
  }
}

class _TagColors {
  final Color background;
  final Color border;
  final Color foreground;

  const _TagColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}
