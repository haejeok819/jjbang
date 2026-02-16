import 'favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoritesRepository implements FavoritesRepository {
  static const _k = 'favorite_combo_ids';

  @override
  Future<Set<String>> loadIds() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? <String>[];
    return list.toSet();
  }

  @override
  Future<void> saveIds(Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_k, ids.toList());
  }
}
