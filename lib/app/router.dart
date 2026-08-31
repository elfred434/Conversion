import 'package:go_router/go_router.dart';
import 'package:english_conversation_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:english_conversation_app/presentation/screens/home/home_screen.dart';
import 'package:english_conversation_app/presentation/screens/conversation/conversation_screen.dart';

/// Configuration centralisee des routes (GoRouter).
final router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/conversation',
      builder: (context, state) => const ConversationScreen(),
    ),
  ],
);
