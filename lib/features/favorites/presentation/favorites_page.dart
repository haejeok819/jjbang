import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../combos/state/combos_providers.dart';
import '../../combos/presentation/combo_detail_page.dart';
import '../state/favorites_notifier.dart';

enum FavoritesSort { popularity, name }

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  FavoritesSort _sort = FavoritesSort.popularity;

  @override
  Widget build(BuildContext context) {
    final favIds = ref.watch(favoritesIdsProvider);
    final combosAsync = ref.watch(combosProvider);

    return combosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) {
        final favItems = items.where((c) => favIds.contains(c.id)).toList();

        if (favItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '아직 즐겨찾기한 조합이 없어요',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text('조합 탭에서 하트를 눌러 저장해보세요 🙂'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      DefaultTabController.maybeOf(context);
                      Navigator.of(context).maybePop();
                    },
                    child: const Text('조합 보러가기'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_sort == FavoritesSort.popularity) {
          favItems.sort((a, b) => b.popularity.compareTo(a.popularity));
        } else {
          favItems.sort((a, b) => a.name.compareTo(b.name));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Text(
                    '저장됨',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  Text('${favItems.length}개'),
                  const Spacer(),
                  DropdownButton<FavoritesSort>(
                    value: _sort,
                    underline: const SizedBox.shrink(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _sort = v);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: FavoritesSort.popularity,
                        child: Text('인기순'),
                      ),
                      DropdownMenuItem(
                        value: FavoritesSort.name,
                        child: Text('이름순'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: favItems.length,
                itemBuilder: (context, i) {
                  final c = favItems[i];
                  return Card(
                    child: ListTile(
                      title: Text(c.name),
                      subtitle: Text('${c.base.type} (${c.base.ratio})'),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () => ref
                            .read(favoritesNotifierProvider.notifier)
                            .toggle(c.id),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ComboDetailPage(comboId: c.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
