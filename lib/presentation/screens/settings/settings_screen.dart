import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:english_conversation_app/config/llm_providers.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late LlmProvider _provider;
  bool _autoSpeak = false;
  final _keyCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _baseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsNotifierProvider);
    _provider = s.provider;
    _autoSpeak = s.autoSpeak;
    _keyCtrl.text = s.apiKey;
    _modelCtrl.text =
        s.model.isNotEmpty ? s.model : kLlmProviders[_provider]!.defaultModel;
    _baseCtrl.text = s.baseUrl;
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _modelCtrl.dispose();
    _baseCtrl.dispose();
    super.dispose();
  }

  void _onProviderChanged(LlmProvider? p) {
    if (p == null) return;
    setState(() {
      _provider = p;
      _modelCtrl.text = kLlmProviders[p]!.defaultModel;
    });
  }

  Future<void> _save() async {
    ref.read(settingsNotifierProvider.notifier).update(
          provider: _provider,
          apiKey: _keyCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          autoSpeak: _autoSpeak,
          baseUrl: _baseCtrl.text.trim(),
        );
    await ref.read(settingsNotifierProvider.notifier).save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parametres enregistres')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = kLlmProviders[_provider]!;
    final isLocal = _provider == LlmProvider.ollama;
    return Scaffold(
      appBar: AppBar(title: const Text('Parametres LLM')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButton<LlmProvider>(
              value: _provider,
              hint: const Text('Fournisseur'),
              items: kLlmProviders.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key, child: Text(e.value.label)))
                  .toList(),
              onChanged: _onProviderChanged,
            ),
            const SizedBox(height: 16),
            if (!isLocal)
              TextField(
                controller: _keyCtrl,
                decoration: const InputDecoration(
                    labelText: 'Cle API', hintText: 'sk-... / AIza...'),
                obscureText: true,
              ),
            if (!isLocal) const SizedBox(height: 16),
            if (isLocal)
              TextField(
                controller: _baseCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL Ollama',
                  hintText: 'http://192.168.1.20:11434/v1',
                ),
              ),
            if (isLocal) const SizedBox(height: 16),
            TextField(
              controller: _modelCtrl,
              decoration: InputDecoration(
                  labelText: 'Modele', hintText: 'ex: ${meta.defaultModel}'),
            ),
            if (isLocal)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Demarre Ollama sur ta machine (ollama serve) et pull un petit '
                  'modele, ex: ollama pull gemma2:2b. Aucune cle, tout reste en local.',
                  style: TextStyle(fontSize: 12),
                ),
              )
            else if (meta.hint.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(meta.hint,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            SwitchListTile(
              title: const Text('Lecture automatique (TTS)'),
              subtitle: const Text('Le tuteur lit ses reponses a voix haute'),
              value: _autoSpeak,
              onChanged: (v) => setState(() => _autoSpeak = v),
            ),
            const Divider(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                await ref.read(historyRepositoryProvider).clearAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Historique efface')),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Effacer l\'historique'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sans cle : Ollama (local, modele en fichier). Avec cle : OpenAI, '
              'OpenRouter, Google AI Studio (Gemini), Groq... La cle reste stockee localement.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
