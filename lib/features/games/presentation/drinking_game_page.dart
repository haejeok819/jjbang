import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum GameMood {
  light('가볍게', 'light'),
  talk('토크', 'talk'),
  action('액션', 'action');

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

      if (!mounted) {
        return;
      }

      setState(() {
        _missionsByMood = loaded;
        _loading = false;
        _loadError = null;
        _round = 0;
        _currentMission = null;
        _resetDeck();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = '미션 데이터를 불러오지 못했어요. ($e)';
      });
    }
  }

  void _resetDeck() {
    final missions = _missionsByMood[_selectedMood] ?? const <String>[];
    final original = List<String>.from(missions);
    original.shuffle(_random);
    _deck = original;
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
    if (_selectedMood == mood) {
      return;
    }

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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '랜덤 술게임',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: GameMood.values
                .map(
                  (mood) => ChoiceChip(
                    label: Text(mood.label),
                    selected: _selectedMood == mood,
                    onSelected: (_) => _changeMood(mood),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentMission ?? '아래 버튼을 눌러 미션을 시작해보세요 🍻',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '라운드 $_round · 남은 미션 ${_deck.length}개',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              FilledButton.icon(
                onPressed: _pickMission,
                icon: const Icon(Icons.casino),
                label: Text(_currentMission == null ? '미션 시작' : '다음 미션'),
              ),
              if (_burstSeed > 0)
                IgnorePointer(
                  child: _MissionBurst(seed: _burstSeed),
                ),
            ],
          ),
          const Spacer(),
          Text(
            'TIP: 과음은 금물! 물도 같이 마셔요 💧',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionBurst extends StatelessWidget {
  const _MissionBurst({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final random = Random(seed);
    final particles = List.generate(14, (_) {
      final angle = random.nextDouble() * pi * 2;
      final distance = 26 + random.nextDouble() * 34;
      return (
        dx: cos(angle) * distance,
        dy: sin(angle) * distance,
        icon: random.nextBool() ? Icons.star_rounded : Icons.circle,
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
        size: 8.0 + random.nextDouble() * 10,
      );
    });

    return TweenAnimationBuilder<double>(
      key: ValueKey(seed),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Opacity(
          opacity: (1 - t).clamp(0, 1),
          child: SizedBox(
            width: 220,
            height: 90,
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
