import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart' as rec;

/// Enregistre un court extrait WAV 16 kHz mono (requis par Azure) puis
/// renvoie les octets audio pour l'evaluation phonetique.
/// (prefixe `rec` pour eviter le conflit avec le type natif `Record` de Dart 3)
class AudioRecorder {
  final rec.Record _recorder = rec.Record();
  bool _isRecording = false;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start() async {
    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission denied');
    }
    final path =
        '${Directory.systemTemp.path}/pron_${DateTime.now().microsecondsSinceEpoch}.wav';
    await _recorder.start(
      path: path,
      config: const rec.RecordConfig(
        encoder: rec.AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    _isRecording = true;
  }

  Future<Uint8List> stop() async {
    final path = await _recorder.stop();
    _isRecording = false;
    return await File(path).readAsBytes();
  }

  bool get isRecording => _isRecording;

  Future<void> dispose() => _recorder.dispose();
}
