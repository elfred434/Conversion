/// Niveaux CEFR utilises par l'app (tous niveaux, selection dans l'UI).
enum CefrLevel { a1, a2, b1, b2, c1, c2 }

extension CefrLevelX on CefrLevel {
  /// Libelle affiche a l'utilisateur (francais).
  String get label {
    switch (this) {
      case CefrLevel.a1:
        return 'A1 · Débutant';
      case CefrLevel.a2:
        return 'A2 · Élémentaire';
      case CefrLevel.b1:
        return 'B1 · Intermédiaire';
      case CefrLevel.b2:
        return 'B2 · Intermédiaire avancé';
      case CefrLevel.c1:
        return 'C1 · Autonome';
      case CefrLevel.c2:
        return 'C2 · Maîtrise';
    }
  }

  /// Instruction integree au system prompt du LLM pour calibrer la difficulte.
  String get instruction {
    switch (this) {
      case CefrLevel.a1:
        return 'The learner is a complete beginner (A1). Use very simple words '
            'and very short sentences. Be patient and encouraging.';
      case CefrLevel.a2:
        return 'The learner is elementary (A2). Use simple, everyday vocabulary '
            'and short sentences.';
      case CefrLevel.b1:
        return 'The learner is intermediate (B1). Use natural conversation and '
            'gently correct grammar mistakes.';
      case CefrLevel.b2:
        return 'The learner is upper-intermediate (B2). Use natural, fluent '
            'English, introduce some idioms, and correct mistakes subtly.';
      case CefrLevel.c1:
        return 'The learner is advanced (C1). Use rich vocabulary and natural '
            'phrasing, and challenge them with nuance.';
      case CefrLevel.c2:
        return 'The learner is near-native (C2). Use sophisticated, idiomatic '
            'English.';
    }
  }
}

/// Construit le system prompt envoye au LLM en fonction du niveau et
/// eventuellement d'un scenario.
String buildSystemPrompt(CefrLevel level, {String? scenarioPrompt}) {
  final base = '''
You are a friendly English conversation partner helping the user practice spoken English.
${level.instruction}
Keep replies concise and conversational (2-4 sentences). If the user makes a mistake, mention a brief correction after your reply.
''';
  if (scenarioPrompt != null) return '$base\n\nScenario: $scenarioPrompt';
  return base;
}
