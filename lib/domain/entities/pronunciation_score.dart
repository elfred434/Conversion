import 'dart:math';

/// Un mot cible et si l'utilisateur l'a prononce correctement (similarite).
class PronWord {
  final String word;
  final bool matched;
  const PronWord(this.word, this.matched);
}

/// Phrases du quotidien pour la pratique de la prononciation.
const List<String> kDailyPhrases = [
  "Could you pass me the salt, please?",
  "I'm going to the grocery store after work.",
  "What time does the bus usually leave?",
  "I'd like a coffee with milk, thanks.",
  "Can you tell me how to get to the station?",
  "I forgot my umbrella at home today.",
  "We are having dinner at seven this evening.",
  "She called me as soon as she arrived.",
  "Do you want to watch a movie tonight?",
  "I need to wake up early tomorrow morning.",
];

String _normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r"[^a-z0-9' ]"), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

int _levenshtein(String a, String b) {
  final m = a.length, n = b.length;
  if (m == 0) return n;
  if (n == 0) return m;
  var prev = List<int>.generate(n + 1, (i) => i);
  var curr = List<int>.filled(n + 1, 0);
  for (var i = 1; i <= m; i++) {
    curr[0] = i;
    for (var j = 1; j <= n; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = [
        curr[j - 1] + 1,
        prev[j] + 1,
        prev[j - 1] + cost,
      ].reduce(min);
    }
    final tmp = prev;
    prev = curr;
    curr = tmp;
  }
  return prev[n];
}

double _similarity(String a, String b) {
  if (a == b) return 1.0;
  final maxLen = max(a.length, b.length);
  if (maxLen == 0) return 1.0;
  return 1 - _levenshtein(a, b) / maxLen;
}

/// Compare la phrase cible et la transcription, mot par mot.
List<PronWord> scoreWords(String target, String transcript) {
  final tWords = _normalize(target).split(' ').where((w) => w.isNotEmpty).toList();
  final uWords = _normalize(transcript).split(' ').where((w) => w.isNotEmpty).toList();
  return [
    for (final tw in tWords)
      PronWord(tw, uWords.any((uw) => _similarity(tw, uw) >= 0.8)),
  ];
}

/// Score global de 0.0 a 1.0 (proportion de mots cibles reconnus).
double pronunciationScore(String target, String transcript) {
  final words = scoreWords(target, transcript);
  if (words.isEmpty) return 0.0;
  return words.where((w) => w.matched).length / words.length;
}
