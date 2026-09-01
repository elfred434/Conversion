import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:english_conversation_app/domain/entities/pronunciation_score.dart';

/// Ecran de pratique de la prononciation : repete une phrase, on note le score.
class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});
  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  final _speech = SpeechToText();
  final _rng = Random();
  String _target = kPracticePhrases[0];
  String _transcript = '';
  String _scoreLabel = '';
  List<PronWord> _words = [];
  bool _isListening = false;
  bool _done = false;

  void _nextPhrase() {
    setState(() {
      _target = kPracticePhrases[_rng.nextInt(kPracticePhrases.length)];
      _transcript = '';
      _scoreLabel = '';
      _words = [];
      _done = false;
    });
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Autorise le micro pour la prononciation.')));
      }
      return;
    }
    final available = await _speech.initialize(
      onError: (e) => debugPrint('speech error: $e'),
    );
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Reconnaissance vocale indisponible.')));
      }
      return;
    }
    setState(() {
      _isListening = true;
      _transcript = '';
      _words = [];
      _scoreLabel = '';
      _done = false;
    });
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'en_US'),
      onResult: (result) {
        _transcript = result.recognizedWords;
        if (result.finalResult) {
          _speech.stop();
          if (mounted) setState(() => _isListening = false);
          _score();
        }
      },
    );
  }

  void _score() {
    final words = scoreWords(_target, _transcript);
    final score = pronunciationScore(_target, _transcript);
    setState(() {
      _words = words;
      _scoreLabel = '${(score * 100).round()}%';
      _done = true;
    });
  }

  List<Widget> _displayWords() {
    if (_words.isEmpty) {
      return _target
          .split(' ')
          .map((w) => Text(w, style: const TextStyle(fontSize: 20)))
          .toList();
    }
    return _words
        .map((w) => Text(
              w.word,
              style: TextStyle(
                fontSize: 20,
                color: w.matched ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prononciation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Répète cette phrase à voix haute :',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(spacing: 6, runSpacing: 6, children: _displayWords()),
              ),
            ),
            const SizedBox(height: 16),
            if (_done)
              Center(
                child: Column(
                  children: [
                    Text(_scoreLabel,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo)),
                    const SizedBox(height: 8),
                    Text(
                      'Tu as dit : "${_transcript.isEmpty ? '—' : _transcript}"',
                      style: const TextStyle(
                          fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _isListening ? null : _toggleListen,
                  backgroundColor: _isListening ? Colors.red : null,
                  child: Icon(_isListening ? Icons.stop : Icons.mic),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _nextPhrase,
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
