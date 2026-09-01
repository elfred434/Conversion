import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:english_conversation_app/domain/entities/pronunciation_score.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';
import 'package:english_conversation_app/presentation/providers/tts_provider.dart';

/// Ecran de pratique de la prononciation :
/// - l'utilisateur peut saisir SA phrase et l'ecouter (TTS) pour en capter la prononciation,
/// - ou choisir une phrase du quotidien,
/// - puis il la REPETE (micro/STT) et on note la ressemblance.
class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});
  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  final SpeechToText _speech = SpeechToText();
  final Random _rng = Random();
  final _freeCtrl = TextEditingController();

  String _target = kDailyPhrases[0];
  String _transcript = '';
  double _score = 0;
  List<PronWord> _words = [];
  bool _isListening = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final practice = ref.read(practicePhraseProvider);
    if (practice != null && practice.isNotEmpty) {
      _target = practice;
      ref.read(practicePhraseProvider.notifier).state = null;
    }
  }

  void _setTarget(String t) {
    setState(() {
      _target = t;
      _transcript = '';
      _score = 0;
      _words = [];
      _done = false;
    });
  }

  Future<void> _listenTarget() async {
    final tts = ref.read(flutterTtsProvider);
    await tts.setLanguage('en-US');
    await tts.speak(_target);
  }

  /// Lit a voix haute la phrase saisie par l'utilisateur (et la prend comme cible).
  Future<void> _readMine() async {
    final text = _freeCtrl.text.trim();
    if (text.isEmpty) return;
    _setTarget(text);
    final tts = ref.read(flutterTtsProvider);
    await tts.setLanguage('en-US');
    await tts.speak(text);
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Autorise le micro.')));
      }
      return;
    }
    final available = await _speech.initialize(
        onError: (e) => debugPrint('speech error: $e'));
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Reconnaissance vocale indisponible.')));
      }
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'en_US'),
      onResult: (result) {
        _transcript = result.recognizedWords;
        if (result.finalResult) {
          _speech.stop();
          if (mounted) setState(() => _isListening = false);
          _scoreWords();
        }
      },
    );
  }

  void _scoreWords() {
    final words = scoreWords(_target, _transcript);
    setState(() {
      _words = words;
      _score = pronunciationScore(_target, _transcript);
      _done = true;
    });
  }

  @override
  void dispose() {
    _freeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prononciation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Ta phrase (optionnel)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _freeCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Ecris une phrase en anglais…'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  tooltip: 'Lire ma phrase',
                  onPressed: _readMine,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Phrases du quotidien',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kDailyPhrases
                  .map((p) => ActionChip(
                        label: Text(p),
                        onPressed: () => _setTarget(p),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_target,
                          style: const TextStyle(fontSize: 20)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      tooltip: 'Ecouter',
                      onPressed: _listenTarget,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_done)
              Column(
                children: [
                  Center(
                    child: Text('${(_score * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo)),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                        'Tu as dit : "${_transcript.isEmpty ? '—' : _transcript}"',
                        style: const TextStyle(
                            fontSize: 14, fontStyle: FontStyle.italic)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _words
                        .map((w) => Text(
                              w.word,
                              style: TextStyle(
                                fontSize: 18,
                                color: w.matched
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _toggleListen,
                  backgroundColor: _isListening ? Colors.red : null,
                  child: Icon(_isListening ? Icons.stop : Icons.mic),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () =>
                      _setTarget(kDailyPhrases[_rng.nextInt(kDailyPhrases.length)]),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Phrase suivante'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
