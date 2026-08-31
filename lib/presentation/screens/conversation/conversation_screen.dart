import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);

    // Auto-scroll quand le nombre de messages change.
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Écris en anglais…',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
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
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
