import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jjbang/features/favorites/presentation/favorites_page.dart';
import 'package:jjbang/features/favorites/state/favorites_notifier.dart';
import 'package:jjbang/features/games/presentation/drinking_game_page.dart';

import 'package:jjbang/features/combos/presentation/combo_detail_dialog.dart';
import 'package:jjbang/features/combos/presentation/widgets/combos_appbar_search.dart';
import 'package:jjbang/features/combos/application/filtered_combo_provider.dart';
import 'package:jjbang/features/combos/application/combo_filter_state.dart';
import 'package:jjbang/features/combos/application/combos_providers.dart' as app;

import 'package:jjbang/shared/widgets/pressable.dart';

class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({super.key});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
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
    final isEnabled = i == _tabCombos || i == _tabGames || i == _tabFavorites;
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
      const _ComingSoonScreen(title: '칵테일 레시피'),
      const DrinkingGamePage(),
      const _ComingSoonScreen(title: '밸런스 게임'),
      const FavoritesPage(),
    ];

    final titles = <String>['주정뱅이', '칵테일 레시피', '술게임', '밸런스 게임', '즐겨찾기'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_index],
          style: _index == _tabFavorites
              ? const TextStyle(fontFamily: 'NanumSquare', fontWeight: FontWeight.w800)
              : null,
        ),
        centerTitle: true,
        actions: [
          if (_index == _tabCombos)
            Consumer(
              builder: (context, ref, _) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final cur = ref.read(app.combosSearchOpenProvider);

                    if (cur) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      ref.read(comboFilterProvider.notifier).setQuery('');
                    }

                    ref.read(app.combosSearchOpenProvider.notifier).state = !cur;
                  },
                );
              },
            ),
        ],
      ),
      body: _index == _tabCombos
          ? Column(
        children: const [
          CombosAppbarSearch(),
          Expanded(child: _CombosScreen()),
        ],
      )
          : pages[_index],
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
            label: '칵테일 레시피',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: '술게임',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: '밸런스 게임',
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
    final asyncCombos = ref.watch(filteredComboProvider);
    final favIds = ref.watch(favoritesIdsProvider);

    void openCombo(String id) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'combo_detail',
        barrierColor: Colors.black.withOpacity(0.45),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return Center(
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ComboDetailDialog(comboId: id),
            ),
          );
        },
        transitionBuilder: (context, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
          final scale = Tween<double>(begin: 0.92, end: 1.0).animate(curved);
          final slide = Tween<double>(begin: 28.0, end: 0.0).animate(curved);

          return FadeTransition(
            opacity: fade,
            child: Transform.translate(
              offset: Offset(0, slide.value),
              child: Transform.scale(
                scale: scale.value,
                child: child,
              ),
            ),
          );
        },
      );
    }

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
            final isFav = favIds.contains(c.id);

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 12),
                    child: child,
                  ),
                );
              },
              child: Pressable(
                onTap: () => openCombo(c.id),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                              ),
                              onPressed: () => ref
                                  .read(favoritesNotifierProvider.notifier)
                                  .toggle(c.id),
                            ),
                          ],
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title 탭 (추후 업데이트 예정)'));
  }
}
