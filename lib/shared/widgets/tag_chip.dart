import 'package:flutter/material.dart';
import 'package:jjbang/core/theme/colors.dart';

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
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: style.foreground,
        ),
      ),
    );
  }

  _TagColors _styleFor(TagType type) {
    switch (type) {
      case TagType.base:
      case TagType.alcohol:
      case TagType.difficulty:
      case TagType.taste:
      case TagType.extra:
        return const _TagColors(
          background: AppColors.chipDefault,
          border: Color(0x00FFFFFF),
          foreground: AppColors.textPrimary,
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
