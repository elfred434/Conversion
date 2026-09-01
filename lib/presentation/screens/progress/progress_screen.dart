import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';

/// Ecran de progression : badges + suivi des types d'erreurs corrigees.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  String _labelCat(String c) {
    switch (c) {
      case 'article':
        return 'Articles';
      case 'preposition':
        return 'Prépositions';
      case 'tense':
        return 'Temps';
      case 'spelling':
        return 'Orthographe';
      case 'word_order':
        return 'Ordre des mots';
      default:
        return c;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ma progression')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erreur de chargement.')),
        data: (s) {
          final badges = <Widget>[
            Chip(
              label: Text('🗣️ ${s.total} corrections'),
              backgroundColor: Colors.indigo.shade50,
            ),
          ];
          if (s.total >= 10) {
            badges.add(const Chip(label: Text('🥉 Débutant')));
          }
          if (s.total >= 50) {
            badges.add(const Chip(label: Text('🥈 Apprenti')));
          }
          if (s.total >= 100) {
            badges.add(const Chip(label: Text('🥇 Confirmé')));
          }
          s.byCategory.forEach((cat, count) {
            badges.add(Chip(
              label: Text('📚 ${_labelCat(cat)} : $count'),
              backgroundColor: Colors.green.shade50,
            ));
          });
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Badges',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: badges),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(progressRepositoryProvider).clear();
                    ref.invalidate(progressProvider);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Réinitialiser la progression'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
