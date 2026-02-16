import 'ingredient.dart';

class ComboBase {
  final String type;
  final String ratio;

  const ComboBase({
    required this.type,
    required this.ratio,
  });
}

class Combo {
  final String id;
  final String name;

  final ComboBase base;
  final List<Ingredient> mixers;

  final List<String> taste;
  final String alcoholLevel;
  final String difficulty;

  final int popularity;

  final List<String> keywords;
  final List<String> extraTags;

  final List<String> steps;
  final List<String> tools;

  final String? oneLiner;
  final String? warning;

  const Combo({
    required this.id,
    required this.name,
    required this.base,
    required this.mixers,
    required this.taste,
    required this.alcoholLevel,
    required this.difficulty,
    required this.popularity,
    required this.keywords,
    required this.extraTags,
    required this.steps,
    required this.tools,
    this.oneLiner,
    this.warning,
  });
}
