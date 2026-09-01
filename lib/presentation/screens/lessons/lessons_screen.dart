import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/domain/entities/lesson.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';
import 'package:english_conversation_app/presentation/providers/tts_provider.dart';

/// Lecons embarquees (hors-ligne) : on ecoute la phrase (TTS) puis on
/// peut la pratiquer (ouvre l'ecran de prononciation avec cette phrase).
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lecons')),
      body: lessons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erreur de chargement.')),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Lecons hors-ligne (aucun reseau requis).',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            ...list.map((lesson) => _LessonCard(lesson: lesson)),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends ConsumerWidget {
  final Lesson lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(lesson.title),
        subtitle: Text(lesson.description),
        children: lesson.phrases
            .map((p) => ListTile(
                  title: Text(p.en,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(p.fr),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        tooltip: 'Ecouter',
                        onPressed: () async {
                          final tts = ref.read(flutterTtsProvider);
                          await tts.setLanguage('en-US');
                          await tts.speak(p.en);
                        },
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ref.read(practicePhraseProvider.notifier).state = p.en;
                          context.go('/pronunciation');
                        },
                        child: const Text('Pratiquer'),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
