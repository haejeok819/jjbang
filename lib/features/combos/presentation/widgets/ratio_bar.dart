import 'package:flutter/material.dart';

class RatioItem {
  final String label;
  final String ratioText;

  const RatioItem({
    required this.label,
    required this.ratioText,
  });
}

class RatioBar extends StatelessWidget {
  final List<RatioItem> items;

  const RatioBar({
    super.key,
    required this.items,
  });

  double _parseRatio(String s) {
    final t = s.trim();

    final numeric = double.tryParse(t);
    if (numeric != null) return numeric;

    if (t.contains('/')) {
      final parts = t.split('/');
      if (parts.length == 2) {
        final a = double.tryParse(parts[0].trim());
        final b = double.tryParse(parts[1].trim());
        if (a != null && b != null && b != 0) return a / b;
      }
    }

    final lower = t.toLowerCase();
    if (lower.contains('약간') || lower.contains('조금')) return 0.5;
    if (lower.contains('적당') || lower.contains('to taste')) return 1.0;

    return 0.3;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final values = items.map((e) => _parseRatio(e.ratioText)).toList();
    final total = values.fold<double>(0, (p, c) => p + c);

    final weights = values.map((v) {
      final w = total == 0 ? 1 : (v / total * 100);
      final i = w.round();
      return i <= 0 ? 1 : i;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            child: Row(
              children: List.generate(items.length, (i) {
                final w = weights[i];
                return Expanded(
                  flex: w,
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(items.length, (i) {
          final pct = total == 0 ? 0 : (values[i] / total * 100);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    items[i].label,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  items[i].ratioText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
