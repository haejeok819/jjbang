import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jjbang/features/favorites/presentation/favorites_page.dart';
import 'package:jjbang/features/favorites/state/favorites_notifier.dart';
import 'package:jjbang/features/games/presentation/drinking_game_page.dart';

import 'package:jjbang/features/combos/domain/combo.dart';
import 'package:jjbang/features/combos/presentation/combo_detail_dialog.dart';
import 'package:jjbang/features/combos/presentation/widgets/combo_sort_chips.dart';
import 'package:jjbang/features/combos/presentation/widgets/combos_appbar_search.dart';
import 'package:jjbang/features/combos/application/combo_filter_state.dart';
import 'package:jjbang/features/combos/application/filtered_combo_provider.dart';
import 'package:jjbang/features/combos/application/combos_providers.dart' as app;

import 'package:jjbang/shared/widgets/favorite_heart_button.dart';
import 'package:jjbang/shared/widgets/pressable.dart';
import 'package:jjbang/shared/widgets/tag_chip.dart';

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
        centerTitle: true,
        toolbarHeight: _index == _tabCombos ? 72 : 100,
        title: _index == _tabCombos
            ? Image.asset(
                'assets/logo.png',
                height: 44,
                fit: BoxFit.contain,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    titles[_index],
                    style: const TextStyle(
                      fontFamily: 'NanumSquare',
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
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
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ComboSortChips(),
                ),
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

            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 112),
              child: _ComboCard(
                combo: c,
                isFav: isFav,
                onTap: () => openCombo(c.id),
                onToggleFavorite: () =>
                    ref.read(favoritesNotifierProvider.notifier).toggle(c.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _ComboCard extends StatelessWidget {
  const _ComboCard({
    required this.combo,
    required this.isFav,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Combo combo;
  final bool isFav;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;

    return Pressable(
      onTap: onTap,
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: _alcoholBarColor(combo.alcoholLevel),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  combo.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'NanumSquare',
                                  ),
                                ),
                              ),
                              FavoriteHeartButton(
                                isFav: isFav,
                                onPressed: onToggleFavorite,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TagChip(label: combo.base.type, type: TagType.base),
                              TagChip(
                                label: '도수 ${combo.alcoholLevel}',
                                type: TagType.alcohol,
                              ),
                              TagChip(
                                label: '난이도 ${combo.difficulty}',
                                type: TagType.difficulty,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: combo.taste
                                .map((t) => TagChip(label: t, type: TagType.taste))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (combo.popularity >= 95)
            Positioned(
              top: 10,
              right: 10,
              child: Badge(
                label: const Text('HOT'),
                backgroundColor: const Color(0xFFFF5C5C),
                textColor: Colors.white,
                child: const SizedBox(width: 20, height: 20),
              ),
            ),
        ],
      ),
    );
  }

  Color _alcoholBarColor(String alcoholLevel) {
    switch (alcoholLevel) {
      case '낮음':
        return const Color(0xFF3BA7FF);
      case '중간':
        return const Color(0xFFFFB547);
      case '높음':
        return const Color(0xFFFF5C5C);
      default:
        return const Color(0xFFB8C0CC);
    }
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title 탭 (추후 업데이트 예정)'));
  }
}
