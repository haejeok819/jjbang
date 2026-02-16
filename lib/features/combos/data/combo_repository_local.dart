import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/combo.dart';
import 'combo_repository.dart';

class LocalComboRepository implements ComboRepository {
  @override
  Future<List<Combo>> getCombos() async {
    final jsonString = await rootBundle.loadString('assets/combos.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((e) => Combo.fromJson(e)).toList();
  }
}
