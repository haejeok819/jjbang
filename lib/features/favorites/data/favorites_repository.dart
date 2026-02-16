abstract class FavoritesRepository {
  Future<Set<String>> loadIds();
  Future<void> saveIds(Set<String> ids);
}
