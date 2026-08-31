import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Client Text-To-Speech (lit les reponses du tuteur a voix haute).
final flutterTtsProvider = Provider<FlutterTts>((ref) => FlutterTts());
