import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_conversation_app/config/llm_providers.dart';
import 'package:english_conversation_app/domain/entities/app_settings.dart';
import 'package:english_conversation_app/domain/repositories/conversation_repository.dart';
import 'package:english_conversation_app/domain/repositories/user_repository.dart';
import 'package:english_conversation_app/domain/usecases/start_conversation.dart';
import 'package:english_conversation_app/domain/usecases/send_message.dart';
import 'package:english_conversation_app/domain/usecases/correct_text.dart';
import 'package:english_conversation_app/domain/usecases/get_user_profile.dart';
import 'package:english_conversation_app/data/datasources/remote/openai_client.dart';
import 'package:english_conversation_app/data/datasources/remote/gemini_client.dart';
import 'package:english_conversation_app/data/datasources/remote/llm_client.dart';
import 'package:english_conversation_app/data/datasources/local/profile_local_datasource.dart';
import 'package:english_conversation_app/data/datasources/local/settings_local_datasource.dart';
import 'package:english_conversation_app/data/repositories/conversation_repository_impl.dart';
import 'package:english_conversation_app/data/repositories/user_repository_impl.dart';
import 'package:english_conversation_app/data/repositories/settings_repository_impl.dart';
import 'package:english_conversation_app/domain/repositories/settings_repository.dart';
import 'package:english_conversation_app/presentation/state/chat_notifier.dart';
import 'package:english_conversation_app/presentation/state/chat_state.dart';
import 'package:english_conversation_app/presentation/providers/settings_notifier.dart';

/// Construit le client LLM en fonction des parametres runtime.
LlmClient _buildClient(AppSettings s) {
  final meta = kLlmProviders[s.provider]!;
  final model = s.model.isNotEmpty ? s.model : meta.defaultModel;
  if (meta.isGemini) {
    return GeminiClient(
      apiKey: s.apiKey,
      baseUrl: meta.defaultBaseUrl,
      model: model,
    );
  }
  return OpenAiClient(
    apiKey: s.apiKey,
    baseUrl: meta.defaultBaseUrl,
    model: model,
  );
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
    (ref) => SettingsRepositoryImpl(SettingsLocalDataSource()));

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
        (ref) => SettingsNotifier(ref.watch(settingsRepositoryProvider)));

final llmClientProvider = Provider<LlmClient>(
    (ref) => _buildClient(ref.watch(settingsNotifierProvider)));

final profileLocalDataSourceProvider =
    Provider<ProfileLocalDataSource>((ref) => ProfileLocalDataSource());

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) =>
    ConversationRepositoryImpl(llmClient: ref.watch(llmClientProvider)));

final userRepositoryProvider = Provider<UserRepository>(
    (ref) => UserRepositoryImpl(ref.watch(profileLocalDataSourceProvider)));

final startConversationProvider = Provider<StartConversation>(
    (ref) => StartConversation(ref.watch(conversationRepositoryProvider)));
final sendMessageProvider = Provider<SendMessage>(
    (ref) => SendMessage(ref.watch(conversationRepositoryProvider)));
final correctTextProvider = Provider<CorrectText>(
    (ref) => CorrectText(ref.watch(conversationRepositoryProvider)));
final getUserProfileProvider = Provider<GetUserProfile>(
    (ref) => GetUserProfile(ref.watch(userRepositoryProvider)));

/// Scenario selectionne sur l'ecran d'accueil (passe a la conversation).
final selectedScenarioProvider = StateProvider<String?>((ref) => null);

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier(
          ref.watch(startConversationProvider),
          ref.watch(sendMessageProvider),
          ref.watch(correctTextProvider),
        ));
