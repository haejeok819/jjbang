import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GameMood {
  random('랜덤', 'random'),
  light('지목 게임', 'light'),
  talk('대화 소재', 'talk'),
  action('행동 게임', 'action');

  const GameMood(this.label, this.key);
  final String label;
  final String key;
}

class DrinkingGamePage extends StatefulWidget {
  const DrinkingGamePage({super.key});

  @override
  State<DrinkingGamePage> createState() => _DrinkingGamePageState();
}

class _DrinkingGamePageState extends State<DrinkingGamePage> {
  static const _contentMoods = [GameMood.light, GameMood.talk, GameMood.action];

  final _random = Random();

  Map<GameMood, List<String>> _missionsByMood = const {};
  GameMood _selectedMood = GameMood.random;
  List<String> _deck = const [];
  String? _currentMission;
  int _round = 0;
  int _burstSeed = 0;

  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    try {
      final raw = await rootBundle.loadString('assets/games.json');
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;

      final loaded = <GameMood, List<String>>{};
      for (final mood in _contentMoods) {
        final value = jsonMap[mood.key];
        if (value is! List) {
          throw FormatException('Missing or invalid list for ${mood.key}');
        }
        final missions = value.map((e) => e.toString()).toList(growable: false);
        if (missions.isEmpty) {
          throw FormatException('Empty missions for ${mood.key}');
        }
        loaded[mood] = missions;
      }

      if (!mounted) return;

      setState(() {
        _missionsByMood = loaded;
        _loading = false;
        _loadError = null;
        _round = 0;
        _currentMission = null;
        _resetDeck();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = '미션 데이터를 불러오지 못했어요. ($e)';
      });
    }
  }

  List<String> _poolByMood(GameMood mood) {
    if (mood == GameMood.random) {
      final all = <String>{};
      for (final m in _contentMoods) {
        all.addAll(_missionsByMood[m] ?? const <String>[]);
      }
      return all.toList(growable: false);
    }
    return List<String>.from(_missionsByMood[mood] ?? const <String>[], growable: false);
  }

  void _resetDeck() {
    final pool = _poolByMood(_selectedMood);
    _deck = List<String>.from(pool)..shuffle(_random);
  }

  void _pickMission() {
    if (_deck.isEmpty) {
      _resetDeck();
    }
    if (_deck.isEmpty) {
      return;
    }

    setState(() {
      _currentMission = _deck.removeLast();
      _round += 1;
      _burstSeed += 1;
    });
  }

  void _changeMood(GameMood mood) {
    if (_selectedMood == mood) return;

    setState(() {
      _selectedMood = mood;
      _currentMission = null;
      _round = 0;
      _resetDeck();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadMissions,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  '텐션 올려보자 🔥',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  _selectedMood == GameMood.random
                      ? '모든 주제에서 랜덤으로, 중복 없이 미션이 나와요.'
                      : '선택한 주제 안에서 중복 없이 미션이 나와요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      for (final mood in GameMood.values) ...[
                        ChoiceChip(
                          label: Text(mood.label),
                          selected: _selectedMood == mood,
                          onSelected: (_) => _changeMood(mood),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MissionPanelLarge(
                    mission: _currentMission,
                    round: _round,
                    remaining: _deck.length,
                    onNext: _pickMission, // ✅ 추가
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: const _StartButtonSection(),
              ),
            ],
          ),
        ),
        if (_burstSeed > 0)
          IgnorePointer(
            child: _MissionBurst(seed: _burstSeed),
          ),
      ],
    );
  }
}

class _MissionPanelLarge extends StatelessWidget {
  const _MissionPanelLarge({
    required this.mission,
    required this.round,
    required this.remaining,
    required this.onNext,
  });

  final String? mission;
  final int round;
  final int remaining;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오늘의 미션',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Text(
                      mission ?? '아래 버튼을 눌러 미션을 시작해보세요 🍻',
                      key: ValueKey(mission ?? 'empty'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '라운드 $round · 남은 미션 ${remaining}개',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 60,
              child: FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.casino, size: 22),
                label: Text(
                  mission == null ? '게임 시작' : '다음 주제',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StartButtonSection extends StatelessWidget {
  const _StartButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'TIP: 과음은 금물! 물도 같이 마셔요 💧',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MissionBurst extends StatelessWidget {
  const _MissionBurst({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final random = Random(seed);
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final burstRadius = shortestSide * 0.28;

    final particles = List.generate(32, (_) {
      final angle = random.nextDouble() * pi * 2;
      final distance = burstRadius * (0.45 + random.nextDouble() * 0.9);
      return (
      dx: cos(angle) * distance,
      dy: sin(angle) * distance,
      icon: random.nextBool() ? Icons.star_rounded : Icons.circle,
      color: Colors.primaries[random.nextInt(Colors.primaries.length)],
      size: 16.0 + random.nextDouble() * 30,
      );
    });

    return TweenAnimationBuilder<double>(
      key: ValueKey(seed),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 680),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Opacity(
          opacity: (1 - t).clamp(0, 1),
          child: SizedBox(
            width: shortestSide,
            height: shortestSide,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final p in particles)
                  Transform.translate(
                    offset: Offset(p.dx * t, p.dy * t),
                    child: Icon(
                      p.icon,
                      size: p.size,
                      color: p.color,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
