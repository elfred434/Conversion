class ProgressStats {
  final int total;
  final Map<String, int> byCategory;

  const ProgressStats({this.total = 0, this.byCategory = const {}});
}

abstract class ProgressRepository {
  /// Enregistre une correction d'un type donne (ex: 'article').
  Future<void> recordCorrection(String category);
  Future<ProgressStats> getStats();
  Future<void> clear();
}
