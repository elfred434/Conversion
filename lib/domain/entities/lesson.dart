/// Phrase d'une lecon (anglais + traduction francaise).
class LessonPhrase {
  final String en;
  final String fr;
  const LessonPhrase({required this.en, required this.fr});

  factory LessonPhrase.fromJson(Map<String, dynamic> j) =>
      LessonPhrase(en: j['en'] as String, fr: j['fr'] as String);
}

/// Lecon hors-ligne embarquee dans l'app (assets/lessons).
class Lesson {
  final String id;
  final String title;
  final String description;
  final List<LessonPhrase> phrases;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.phrases,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        phrases: (j['phrases'] as List)
            .map((p) => LessonPhrase.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
