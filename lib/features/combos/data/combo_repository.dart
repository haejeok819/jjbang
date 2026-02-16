import '../domain/combo.dart';

abstract class ComboRepository {
  Future<List<Combo>> getCombos();
}
