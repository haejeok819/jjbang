import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jjbang/features/favorites/presentation/favorites_page.dart';
import 'package:jjbang/features/favorites/state/favorites_notifier.dart';
import 'package:jjbang/features/games/presentation/drinking_game_page.dart';

import 'package:jjbang/features/combos/domain/combo.dart';
import 'package:jjbang/features/combos/presentation/combo_detail_dialog.dart';
import 'package:jjbang/features/combos/presentation/widgets/combo_sort_chips.dart';
import 'package:jjbang/features/combos/presentation/widgets/combo_filter_chips.dart';
import 'package:jjbang/features/combos/application/combo_filter_state.dart';
import 'package:jjbang/features/combos/application/filtered_combo_provider.dart';

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
      const _ComingSoonScreen(title: '칵테일 레시피'),
      const DrinkingGamePage(),
      const _ComingSoonScreen(title: '밸런스 게임'),
      const FavoritesPage(),
    ];


    return Scaffold(
      appBar: _index == _tabCombos
          ? null
          : AppBar(
        centerTitle: true,
        toolbarHeight: 130,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Image.asset(
          'assets/logo.png',
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
      body: _index == _tabCombos ? const _CombosScreen() : pages[_index - 1],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.emoji_food_beverage_outlined),
            selectedIcon: Icon(Icons.emoji_food_beverage),
            label: '술조합',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_bar_outlined),
            selectedIcon: Icon(Icons.local_bar),
            label: '레시피',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: '대화소재',
          ),
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: '술게임',
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

class _CombosScreen extends ConsumerStatefulWidget {
  const _CombosScreen();

  @override
  ConsumerState<_CombosScreen> createState() => _CombosScreenState();
}

class _CombosScreenState extends ConsumerState<_CombosScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCombos = ref.watch(filteredComboProvider);
    final favIds = ref.watch(favoritesIdsProvider);
    final query = ref.watch(comboFilterProvider.select((s) => s.query));

    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    void clearQuery() {
      _searchController.clear();
      ref.read(comboFilterProvider.notifier).setQuery('');
      FocusManager.instance.primaryFocus?.unfocus();
    }

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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          toolbarHeight: 130,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Image.asset(
            'assets/logo.png',
            height: 120,
            fit: BoxFit.contain,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                height: 46,
                child: SearchBar(
                  controller: _searchController,
                  leading: const Icon(Icons.search),
                  hintText: '조합 이름 또는 베이스 술/음료를 검색해보세요 !',
                  onChanged: (value) =>
                      ref.read(comboFilterProvider.notifier).setQuery(value),
                  onSubmitted: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  trailing: [
                    if (query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: '검색어 지우기',
                        onPressed: clearQuery,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedCombosControlsHeaderDelegate(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),

              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: ComboSortChips(),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: ComboFilterChips(),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...asyncCombos.when(
          loading: () => [
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          error: (e, _) => [
            SliverFillRemaining(
              child: Center(child: Text('에러: $e')),
            ),
          ],
          data: (combos) {
            if (combos.isEmpty) {
              return const [
                SliverFillRemaining(
                  child: Center(child: Text('조건에 맞는 술 조합이 없어요')),
                ),
              ];
            }

            return [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final c = combos[i];
                      final isFav = favIds.contains(c.id);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 112),
                          child: _ComboCard(
                            combo: c,
                            isFav: isFav,
                            onTap: () => openCombo(c.id),
                            onToggleFavorite: () =>
                                ref.read(favoritesNotifierProvider.notifier).toggle(c.id),
                          ),
                        ),
                      );
                    },
                    childCount: combos.length,
                  ),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}

class _PinnedCombosControlsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _PinnedCombosControlsHeaderDelegate({required this.child});

  @override
  double get minExtent => 112;

  @override
  double get maxExtent => 112;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedCombosControlsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 112),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 4,
                    child: ColoredBox(
                      color: _baseBarColor(combo.base.type),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  combo.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'NanumSquare',
                                  ),
                                ),
                              ),
                              if (combo.popularity >= 95) ...[
                                const Badge(
                                  label: Text('HOT'),
                                  backgroundColor: Color(0xFFFF5C5C),
                                  textColor: Colors.white,
                                ),
                                const SizedBox(width: 8),
                              ],
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
        ),
      ),
    );
  }





  Color _baseBarColor(String baseType) {
    switch (baseType) {
      case '소주':
        return const Color(0xFF1B5E20);
      case '맥주':
        return const Color(0xFFFFD54F);
      case '막걸리':
        return const Color(0xFF81D4FA);
      case '고량주':
        return const Color(0xFFE53935);
      case '위스키':
        return const Color(0xFF8E24AA);
      case '사이다':
        return const Color(0xFFA5D6A7);
      case '콜라':
        return const Color(0xFF212121);
      case '토닉':
        return const Color(0xFF1E88E5);
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
