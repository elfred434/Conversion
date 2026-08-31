import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_conversation_app/domain/entities/level.dart';

/// Source de donnees locale (SharedPreferences) pour le profil utilisateur.
class ProfileLocalDataSource {
  static const String _key = 'cefr_level';

  Future<CefrLevel?> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return null;
    for (final lvl in CefrLevel.values) {
      if (lvl.name == value) return lvl;
    }
    return CefrLevel.a1;
  }

  Future<void> saveLevel(CefrLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, level.name);
  }
}
