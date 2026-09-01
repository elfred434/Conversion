import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_conversation_app/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  static const _key = 'progress';

  Future<Map<String, dynamic>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return {'total': 0, 'byCategory': <String, dynamic>{}};
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _write(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  Map<String, int> _parseCat(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), (v is num) ? v.toInt() : 0));
  }

  @override
  Future<void> recordCorrection(String category) async {
    final data = await _read();
    data['total'] = (data['total'] as int? ?? 0) + 1;
    final byCat = _parseCat(data['byCategory']);
    byCat[category] = (byCat[category] ?? 0) + 1;
    data['byCategory'] = byCat;
    await _write(data);
  }

  @override
  Future<ProgressStats> getStats() async {
    final data = await _read();
    final byCat = _parseCat(data['byCategory']);
    return ProgressStats(total: data['total'] as int? ?? 0, byCategory: byCat);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
