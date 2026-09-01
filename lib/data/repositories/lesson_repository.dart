import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:english_conversation_app/domain/entities/lesson.dart';

/// Charge les lecons embarquees (assets/lessons/lessons.json).
/// Aucun reseau requis : fonctionne hors-ligne.
class LessonRepository {
  Future<List<Lesson>> loadLessons() async {
    final data =
        await rootBundle.loadString('assets/lessons/lessons.json');
    final list = jsonDecode(data) as List;
    return list
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
