import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';
import 'package:english_conversation_app/domain/entities/conversation_message.dart';
import 'package:english_conversation_app/presentation/providers/tts_provider.dart';
import 'package:english_conversation_app/presentation/widgets/message_bubble.dart';

/// Ecran de conversation (chat avec streaming).
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _speech = SpeechToText();
  bool _isListening = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final level = await ref.read(getUserProfileProvider).call();
    if (!mounted) return;
    if (level == null) {
      context.go('/onboarding');
      return;
    }
    if (ref.read(settingsNotifierProvider).apiKey.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ajoute ta clé API dans les paramètres pour démarrer.')),
      );
      context.push('/settings');
      return;
    }
    if (!_started) {
      _started = true;
      final scenarioId = ref.read(selectedScenarioProvider);
      ref.read(chatProvider.notifier).start(
            level: level,
            scenarioId: scenarioId,
          );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    if (ref.read(settingsNotifierProvider).apiKey.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoute ta clé API dans les paramètres.')),
      );
      context.push('/settings');
      return;
    }
    _controller.clear();
    ref.read(chatProvider.notifier).send(text);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autorise le micro pour la reconnaissance vocale.')),
        );
      }
      return;
    }
    final available = await _speech.initialize(
      onError: (e) => debugPrint('speech error: $e'),
    );
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reconnaissance vocale indisponible sur cet appareil.')),
        );
      }
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'en_US'),
      onResult: (result) {
        _controller.text = result.recognizedWords;
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _speech.stop();
          if (mounted) setState(() => _isListening = false);
          _send();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final autoSpeak = ref.watch(settingsNotifierProvider).autoSpeak;

    // Auto-scroll quand le nombre de messages change.
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    // Lecture automatique des reponses du tuteur (TTS) a la fin du streaming.
    ref.listen(chatProvider, (previous, next) {
      final prevStreaming = previous?.isStreaming ?? false;
      if (prevStreaming && !next.isStreaming) {
        ConversationMessage? last;
        for (final m in next.messages.reversed) {
          if (m.role == MessageRole.assistant && !m.isError) {
            last = m;
            break;
          }
        }
        if (last != null &&
            last.content.isNotEmpty &&
            ref.read(settingsNotifierProvider).autoSpeak) {
          final tts = ref.read(flutterTtsProvider);
          tts.setLanguage('en-US');
          tts.speak(last.content);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(autoSpeak ? Icons.volume_up : Icons.volume_off),
            tooltip: 'Lecture auto',
            onPressed: () {
              final cur = ref.read(settingsNotifierProvider).autoSpeak;
              ref.read(settingsNotifierProvider.notifier).update(autoSpeak: !cur);
              ref.read(settingsNotifierProvider.notifier).save();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.messages.length,
              itemBuilder: (context, index) =>
                  MessageBubble(message: state.messages[index]),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Erreur : ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (state.isStreaming)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
          if (_isListening)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('🎤 Écoute… parle en anglais',
                  style: TextStyle(color: Colors.red)),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Écris ou parle en anglais…',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: state.isStreaming ? null : _toggleListen,
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  color: _isListening ? Colors.red : null,
                  tooltip: 'Reconnaissance vocale',
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  onPressed: state.isStreaming ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
