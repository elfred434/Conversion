/// Scenario / theme de conversation proposé a l'apprenant.
class Scenario {
  final String id;
  final String title;
  final String description;
  final String prompt;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.prompt,
  });
}

/// Scenarios predefinis (extensible : venir depuis une API plus tard).
const List<Scenario> kScenarios = [
  Scenario(
    id: 'daily',
    title: 'La vie quotidienne',
    description: 'Parler de ta journée et de tes habitudes.',
    prompt: 'Talk about daily life, routines and habits with the learner.',
  ),
  Scenario(
    id: 'travel',
    title: 'Voyager',
    description: 'Réserver, demander son chemin, à l’aéroport.',
    prompt: 'Practice travel English: booking, asking for directions, at the airport.',
  ),
  Scenario(
    id: 'work',
    title: 'Au travail',
    description: 'Réunions, e-mails, small talk.',
    prompt: 'Practice professional and workplace English: meetings, emails, small talk.',
  ),
  Scenario(
    id: 'free',
    title: 'Conversation libre',
    description: 'Sujet au choix de l’apprenant.',
    prompt: 'Have a free, open conversation on any topic the learner chooses.',
  ),
];
