/// Scenario / theme de conversation propose a l'apprenant.
class Scenario {
  final String id;
  final String title;
  final String description;
  final String prompt;
  /// true = le tuteur corrige la grammaire ; false = mode "ecoute" (pas de correction).
  final bool correct;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.prompt,
    this.correct = true,
  });
}

/// Scenarios predefinis (extensible : venir depuis une API plus tard).
const List<Scenario> kScenarios = [
  Scenario(
    id: 'daily',
    title: 'La vie quotidienne',
    description: 'Parler de ta journee et de tes habitudes.',
    prompt: 'Talk about daily life, routines and habits with the learner.',
  ),
  Scenario(
    id: 'travel',
    title: 'Voyager',
    description: 'Reserver, demander son chemin, a l’aeroport.',
    prompt: 'Practice travel English: booking, asking for directions, at the airport.',
  ),
  Scenario(
    id: 'work',
    title: 'Au travail',
    description: 'Reunions, e-mails, small talk.',
    prompt: 'Practice professional and workplace English: meetings, emails, small talk.',
  ),
  Scenario(
    id: 'free',
    title: 'Conversation libre',
    description: 'Sujet au choix de l’apprenant.',
    prompt: 'Have a free, open conversation on any topic the learner chooses.',
  ),
  Scenario(
    id: 'myday',
    title: 'Raconte ta journee',
    description: 'Parle de ta journee en anglais — le tuteur t’ecoute, sans correction.',
    prompt: 'The user is practicing English by telling you about their day. Be a warm, '
        'attentive listener. Respond naturally and encouragingly in simple English, and '
        'ask follow-up questions to keep the conversation going. Do NOT correct their '
        'grammar or spelling; your goal is to let them express themselves freely.',
    correct: false,
  ),
];
