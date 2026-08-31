import 'package:flutter/material.dart';
import 'package:english_conversation_app/app/router.dart';
import 'package:english_conversation_app/core/theme/app_theme.dart';

/// Racine de l'application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'English Conversation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
