import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GameMood {
  light('이미지 게임 !', 'light'),
  talk('대화 주제 !', 'talk'),
  action('행동 게임 !', 'action');

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
  final _random = Random();

  Map<GameMood, List<String>> _missionsByMood = const {};
  GameMood _selectedMood = GameMood.light;
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
      for (final mood in GameMood.values) {
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

  void _resetDeck() {
    final missions = _missionsByMood[_selectedMood] ?? const <String>[];
    final original = List<String>.from(missions)..shuffle(_random);
    _deck = original;
  }

  void _pickMission() {
    if (_deck.isEmpty) {
      _resetDeck();
    }
    if (_deck.isEmpty) return;

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '랜덤 술게임',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '주제를 고르고, 하단의 게임 시작 버튼을 눌러보세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ 가로 스크롤 확실히 되게: Row + shrinkWrap 패턴 유지
            SizedBox(
              height: 44,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (final mood in GameMood.values) ...[
                      ChoiceChip(
                        label: Text(mood.label),
                        selected: _selectedMood == mood,
                        onSelected: (_) => _changeMood(mood),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ 미션 영역이 화면 절반 이상 차지
            Expanded(
              flex: 7,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _MissionBottomPanel(
                    mission: _currentMission,
                    round: _round,
                    remaining: _deck.length,
                    onNext: _pickMission,
                  ),
                  IgnorePointer(
                    ignoring: true,
                    child: _MissionBurst(seed: _burstSeed),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionBottomPanel extends StatelessWidget {
  const _MissionBottomPanel({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✅ 카드가 영역 대부분 차지
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  color: Color(0x14000000),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 주제',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),

                // ✅ 미션 텍스트를 크게, 중앙 배치
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Text(
                        mission ?? '아래 버튼을 눌러 게임을 시작해보세요 🍻',
                        key: ValueKey(mission ?? 'empty'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  '라운드 $round · 남은 주제 ${remaining}개',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ✅ 버튼 크게
        SizedBox(
          height: 60,
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.casino, size: 22),
            label: Text(
              mission == null ? '게임 시작' : '다음 주제',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Center(
          child: Text(
            'TIP: 과음은 금물! 물도 같이 마셔요 💧',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
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
