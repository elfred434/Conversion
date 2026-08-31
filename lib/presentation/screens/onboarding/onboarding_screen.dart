import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/domain/entities/level.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';
import 'package:english_conversation_app/presentation/widgets/level_selector.dart';

/// Ecran de choix du niveau (affiche une seule fois, niveau stocke localement).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  CefrLevel? _level;
  bool _saving = false;

  Future<void> _confirm() async {
    if (_level == null) return;
    setState(() => _saving = true);
    await ref.read(getUserProfileProvider).save(_level!);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ton niveau')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélectionne ton niveau d’anglais',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LevelSelector(
              selected: _level,
              onSelected: (level) => setState(() => _level = level),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _level == null || _saving ? null : _confirm,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
