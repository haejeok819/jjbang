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
  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'],
      name: json['name'],
      base: ComboBase(
        type: json['base']['type'],
        ratio: json['base']['ratio'],
      ),
      mixers: (json['mixers'] as List)
          .map((e) => Ingredient(
        name: e['name'],
        ratio: e['ratio'],
      ))
          .toList(),
      taste: List<String>.from(json['taste']),
      alcoholLevel: json['alcoholLevel'],
      difficulty: json['difficulty'],
      popularity: json['popularity'],
      keywords: List<String>.from(json['keywords']),
      extraTags: List<String>.from(json['extraTags']),
      steps: List<String>.from(json['steps']),
      tools: List<String>.from(json['tools']),
      oneLiner: json['oneLiner'],
      warning: json['warning'],
    );
  }

}
