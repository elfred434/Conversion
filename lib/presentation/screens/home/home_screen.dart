import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/domain/entities/scenario.dart';
import 'package:english_conversation_app/domain/usecases/get_user_profile.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';

/// Ecran d'accueil : affiche le niveau et propose les scenarios.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(getUserProfileProvider);

    return FutureBuilder<CefrLevel?>(
      future: profile.call(),
      builder: (context, snapshot) {
        final level = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: const Text('English Conversation')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveau : ${level?.label ?? '—'}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Choisis un scénario',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: kScenarios.map((scenario) {
                      return Card(
                        child: ListTile(
                          title: Text(scenario.title),
                          subtitle: Text(scenario.description),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            ref.read(selectedScenarioProvider.notifier).state =
                                scenario.id;
                            context.go('/conversation');
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(selectedScenarioProvider.notifier).state = null;
                    context.go('/conversation');
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Conversation libre'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
