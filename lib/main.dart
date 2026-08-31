import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/app/app.dart';
import 'package:english_conversation_app/presentation/providers/providers.dart';
import 'package:english_conversation_app/presentation/providers/settings_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  final settings = await container.read(settingsRepositoryProvider).load();
  container.read(settingsNotifierProvider.notifier).state = settings;
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
