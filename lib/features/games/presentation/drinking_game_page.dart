import 'dart:math';

import 'package:flutter/material.dart';

enum GameMood {
  light('가볍게'),
  talk('토크'),
  action('액션');

  const GameMood(this.label);
  final String label;
}

class DrinkingGamePage extends StatefulWidget {
  const DrinkingGamePage({super.key});

  @override
  State<DrinkingGamePage> createState() => _DrinkingGamePageState();
}

class _DrinkingGamePageState extends State<DrinkingGamePage> {
  final _random = Random();
  final Map<GameMood, List<String>> _missionsByMood = {
    GameMood.light: const [
      '모든 사람과 건배하기',
      '오늘의 안주 원픽 말하기',
      '옆 사람 칭찬 1개 하기',
      '물 한 모금 마시기(수분 보충)',
      '왼쪽 사람과 하이파이브 하기',
    ],
    GameMood.talk: const [
      '최근 가장 웃겼던 일 1개 말하기',
      '내 휴대폰 배경화면 이유 설명하기',
      '첫인상 vs 지금 인상 한 명 말하기',
      '오늘 기분을 한 단어로 표현하기',
      'TMI 하나 공유하기',
    ],
    GameMood.action: const [
      '가위바위보, 진 사람 한 모금',
      '아무 노래 3초 부르기',
      '끝말잇기 3턴 하기',
      '손가락 게임: 마지막 손 든 사람 한 모금',
      '눈 감고 랜덤으로 사람 한 명 지목해서 건배',
    ],
  };

  GameMood _selectedMood = GameMood.light;
  List<String> _deck = const [];
  String? _currentMission;
  int _round = 0;

  @override
  void initState() {
    super.initState();
    _resetDeck();
  }

  void _resetDeck() {
    final original = List<String>.from(_missionsByMood[_selectedMood]!);
    original.shuffle(_random);
    _deck = original;
  }

  void _pickMission() {
    if (_deck.isEmpty) {
      _resetDeck();
    }

    setState(() {
      _currentMission = _deck.removeLast();
      _round += 1;
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
          FilledButton.icon(
            onPressed: _pickMission,
            icon: const Icon(Icons.casino),
            label: Text(_currentMission == null ? '미션 시작' : '다음 미션'),
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
