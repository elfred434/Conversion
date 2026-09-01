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
  final _azureKeyCtrl = TextEditingController();
  final _azureRegionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsNotifierProvider);
    _provider = s.provider;
    _autoSpeak = s.autoSpeak;
    _keyCtrl.text = s.apiKey;
    _modelCtrl.text = s.model.isNotEmpty ? s.model : kLlmProviders[_provider]!.defaultModel;
    _azureKeyCtrl.text = s.azureKey;
    _azureRegionCtrl.text = s.azureRegion;
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _modelCtrl.dispose();
    _azureKeyCtrl.dispose();
    _azureRegionCtrl.dispose();
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
          azureKey: _azureKeyCtrl.text.trim(),
          azureRegion: _azureRegionCtrl.text.trim(),
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
            TextField(
              controller: _keyCtrl,
              decoration: const InputDecoration(
                  labelText: 'Cle API', hintText: 'sk-... / AIza...'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modelCtrl,
              decoration: const InputDecoration(
                  labelText: 'Modele', hintText: 'ex: gpt-4o-mini'),
            ),
            if (meta.hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(meta.hint,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            SwitchListTile(
              title: const Text('Lecture automatique (TTS)'),
              subtitle: const Text('Le tuteur lit ses reponses a voix haute'),
              value: _autoSpeak,
              onChanged: (v) => setState(() => _autoSpeak = v),
            ),
            const Divider(height: 24),
            const Text('Evaluation phonetique (Azure Speech)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _azureKeyCtrl,
              decoration:
                  const InputDecoration(labelText: 'Cle Azure Speech'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _azureRegionCtrl,
              decoration: const InputDecoration(
                  labelText: 'Region Azure', hintText: 'ex: westeurope'),
            ),
            const SizedBox(height: 24),
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
              'Clee gratuite sur OpenRouter, Google AI Studio (Gemini), Groq, ou '
              'auto-heberge Ollama. La cle reste stockee localement sur l’appareil. '
              'Pour le scoring phonetique, cree une ressource Speech sur Azure '
              '(niveau gratuit) et renseigne sa cle et sa region.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
