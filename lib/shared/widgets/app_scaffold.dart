import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/combos/application/combos_providers.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _index = 0;

  static const int _tabCombos = 0;
  static const int _tabCocktails = 1;
  static const int _tabGames = 2;
  static const int _tabDebates = 3;
  static const int _tabFavorites = 4;

  void _showComingSoon() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('업데이트 알림'),
          content: const Text('아직 업데이트 되지 않았어요 🥹'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('기대할게요!'),
            ),
          ],
        );
      },
    );
  }


  void _onTabSelected(int i) {
    final isEnabled = i == _tabCombos || i == _tabFavorites;
    if (!isEnabled) {
      _showComingSoon();
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _CombosScreen(),
      const _ComingSoonScreen(title: '칵테일'),
      const _ComingSoonScreen(title: '술게임'),
      const _ComingSoonScreen(title: '토론'),
      const _FavoritesScreen(),
    ];

    final titles = <String>[
      '주정뱅이',
      '칵테일',
      '술게임',
      '토론',
      '즐겨찾기',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        centerTitle: true,
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.emoji_food_beverage_outlined),
            selectedIcon: Icon(Icons.emoji_food_beverage),
            label: '조합',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_bar_outlined),
            selectedIcon: Icon(Icons.local_bar),
            label: '칵테일',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: '술게임',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: '토론',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: '즐겨찾기',
          ),
        ],
      ),
    );
  }
}

class _CombosScreen extends ConsumerWidget {
  const _CombosScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCombos = ref.watch(combosProvider);

    return asyncCombos.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('에러: $e')),
      data: (combos) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: combos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final c = combos[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(text: c.base.type),
                        _Pill(text: '도수 ${c.alcoholLevel}'),
                        _Pill(text: '난이도 ${c.difficulty}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: c.taste.map((t) => _Tag(text: t)).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}


class _FavoritesScreen extends StatelessWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('즐겨찾기 탭 (Day 1)'),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$title 탭 (추후 업데이트 예정)'),
    );
  }
}
