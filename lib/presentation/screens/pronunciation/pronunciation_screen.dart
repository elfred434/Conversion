import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:english_conversation_app/domain/entities/pronunciation_score.dart';
import 'package:english_conversation_app/domain/entities/pronunciation_assessment.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';
import 'package:english_conversation_app/presentation/providers/tts_provider.dart';
import 'package:english_conversation_app/presentation/state/audio_recorder.dart';

/// Ecran de pratique de la prononciation :
/// 1) l'utilisateur ECOUTE la phrase (TTS), 2) il la REPETE (micro),
/// 3) on note la prononciation (Azure Phonetic Assessment, ou similarite STT).
class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});
  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final SpeechToText _speech = SpeechToText();
  final Random _rng = Random();

  String _target = kPracticePhrases[0];
  String _transcript = '';
  List<PronWord> _words = [];
  PronunciationAssessment? _azureResult;
  double _similarity = 0;
  bool _isRecording = false;
  bool _isListening = false;
  bool _done = false;
  bool _useAzure = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _target = kPracticePhrases[_rng.nextInt(kPracticePhrases.length)];
    _useAzure =
        ref.read(settingsNotifierProvider).azureKey.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  void _nextPhrase() {
    setState(() {
      _target = kPracticePhrases[_rng.nextInt(kPracticePhrases.length)];
      _transcript = '';
      _words = [];
      _azureResult = null;
      _similarity = 0;
      _done = false;
      _error = '';
    });
  }

  Future<void> _listenPhrase() async {
    final tts = ref.read(flutterTtsProvider);
    await tts.setLanguage('en-US');
    await tts.speak(_target);
  }

  // --- Mode Azure : enregistrement audio reel ---
  Future<void> _toggleRecord() async {
    if (_recorder.isRecording) {
      final bytes = await _recorder.stop();
      setState(() => _isRecording = false);
      try {
        final result = await ref
            .read(pronunciationRepositoryProvider)
            .assess(referenceText: _target, audioBytes: bytes);
        setState(() {
          _azureResult = result;
          _done = true;
        });
      } catch (e) {
        setState(() => _error = e.toString());
      }
      return;
    }
    try {
      await _recorder.start();
      setState(() => _isRecording = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Micro requis : $e')));
      }
    }
  }

  // --- Mode repli : transcription STT + similarite ---
  Future<void> _toggleSpeech() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Autorise le micro.')));
      }
      return;
    }
    final available = await _speech.initialize(
        onError: (e) => debugPrint('speech error: $e'));
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reconnaissance vocale indisponible.')));
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
          _scoreSimilarity();
        }
      },
    );
  }

  void _scoreSimilarity() {
    final words = scoreWords(_target, _transcript);
    setState(() {
      _words = words;
      _similarity = pronunciationScore(_target, _transcript);
      _done = true;
    });
  }

  Color _colorFor(double acc) =>
      acc >= 80 ? Colors.green : (acc >= 50 ? Colors.orange : Colors.red);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prononciation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1) Ecoute la phrase, 2) répète-la à voix haute :',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
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
                      onPressed: _listenPhrase,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_useAzure)
              const Text('Scoring phonétique Azure activé.',
                  style: TextStyle(fontSize: 12, color: Colors.green))
            else
              const Text('Sans clé Azure : scoring par similarité (STT).',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            if (_error.isNotEmpty)
              Text('Erreur : $_error',
                  style: const TextStyle(color: Colors.red)),
            if (_done) _buildResult(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _useAzure ? _toggleRecord : _toggleSpeech,
                  backgroundColor:
                      (_isRecording || _isListening) ? Colors.red : null,
                  child: Icon(_isRecording || _isListening
                      ? Icons.stop
                      : Icons.mic),
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

  Widget _buildResult() {
    if (_azureResult != null) {
      final r = _azureResult!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('${r.overall.round()}%',
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
          ),
          const SizedBox(height: 8),
          _metric('Précision', r.accuracy),
          _metric('Fluidité', r.fluency),
          _metric('Complétude', r.completeness),
          _metric('Prosodie', r.prosody),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: r.words
                .map((w) => Text(w.word,
                    style: TextStyle(
                        fontSize: 18,
                        color: _colorFor(w.accuracy),
                        fontWeight: FontWeight.w600)))
                .toList(),
          ),
        ],
      );
    }
    return Column(
      children: [
        Center(
          child: Text('${(_similarity * 100).round()}%',
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('Tu as dit : "${_transcript.isEmpty ? '—' : _transcript}"',
              style: const TextStyle(
                  fontSize: 14, fontStyle: FontStyle.italic)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _words
              .map((w) => Text(w.word,
                  style: TextStyle(
                      fontSize: 18,
                      color: w.matched ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600)))
              .toList(),
        ),
      ],
    );
  }

  Widget _metric(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 8),
          Text('${value.round()}'),
        ],
      ),
    );
  }
}
