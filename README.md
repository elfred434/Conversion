# English Conversation — App Flutter (Mobile + Desktop)

App conversationnelle d'apprentissage de l'anglais. L'utilisateur choisit son
niveau (A1→C2), sélectionne un scénario, puis discute en anglais avec un
partenaire de conversation alimenté par un **LLM externe** (OpenAI ou Gemini).
Le LLM corrige automatiquement les phrases de l'utilisateur.

## Prérequis

- Flutter SDK ≥ 3.19 (`flutter --version`)
- Un compte + clé API : OpenAI **ou** Google Gemini

## Installation

```bash
cd english_conversation_app
flutter pub get
```

## Lancer (avec ta clé API)

Les clés sont injectées via `--dart-define` (aucune clé n'est commitée).

### Avec OpenAI (defaut)

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-... --dart-define=LLM_PROVIDER=openai
```

### Avec Gemini

```bash
flutter run --dart-define=GEMINI_API_KEY=... --dart-define=LLM_PROVIDER=gemini
```

Lancer sur Desktop : `flutter run -d windows` / `macos` / `linux`.
Lancer sur Mobile : `flutter run` (appareil connecté ou émulateur).

## Changer de fournisseur LLM

Le client est abstraite (`LlmClient`). Le bon client est choisi dans
`lib/presentation/providers/providers.dart` selon `LLM_PROVIDER`.
Pour ajouter un fournisseur : créer `xxx_client.dart` qui implémente
`LlmClient` (`streamChat` + `correctText`), puis l'ajouter dans le provider.

## Structure du projet

```
lib/
├── main.dart                      # point d'entrée
├── app/
│   ├── app.dart                   # MaterialApp + theme
│   └── router.dart                # routes GoRouter
├── config/
│   └── app_config.dart            # lecture des --dart-define
├── core/
│   └── theme/app_theme.dart       # theme Material 3
├── domain/                        # PUR, aucune dépendance UI/SDK
│   ├── entities/                  # Message, Level, Scenario
│   ├── repositories/              # contrats (interfaces)
│   └── usecases/                  # StartConversation, SendMessage, CorrectText, GetUserProfile
├── data/                          # implémentations + sources de données
│   ├── datasources/remote/        # LlmClient, OpenAiClient, GeminiClient
│   ├── datasources/local/         # ProfileLocalDataSource (SharedPreferences)
│   └── repositories/              # *RepositoryImpl
└── presentation/                  # UI (Riverpod + GoRouter)
    ├── providers/                 # graphe de dépendances (providers)
    ├── state/                     # ChatState + ChatNotifier (StateNotifier)
    ├── screens/                   # onboarding, home, conversation
    └── widgets/                   # level_selector, message_bubble
```

Voir `ARCHITECTURE.md` pour le détail des couches et du flux de données.

## Personnalisation rapide

- **Ajouter un scénario** : éditer `lib/domain/entities/scenario.dart`
  (`kScenarios`).
- **Ajuster le ton par niveau** : `lib/domain/entities/level.dart`
  (`instruction` + `buildSystemPrompt`).
- **Changer le modèle** : `model` dans `OpenAiClient` / `GeminiClient`.

## Notes

- Le niveau est persisté localement (SharedPreferences) : l'onboarding
  n'apparaît qu'une fois.
- La correction de phrase est *best-effort* : en cas d'échec de l'appel,
  la conversation continue sans correction.
