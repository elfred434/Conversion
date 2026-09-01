import 'dart:math';

/// Un mot cible et si l'utilisateur l'a prononce correctement (similarite).
class PronWord {
  final String word;
  final bool matched;
  const PronWord(this.word, this.matched);
}

/// Phrases d'entrainement a la prononciation (banque locale, sans API).
const List<String> kPracticePhrases = [
  "Hello, my name is Alex and I am happy to meet you.",
  "I would like a cup of coffee, please.",
  "Where is the train station near here?",
  "She has been working here since last year.",
  "Could you please tell me how to get to the museum?",
  "We were watching a movie when the power went out.",
  "If I had more time, I would learn to play the guitar.",
  "The book on the table belongs to my brother.",
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
