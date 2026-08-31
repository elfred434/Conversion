# Architecture — English Conversation (Flutter)

L'app suit une **Clean Architecture** légère en 3 couches, découplées par des
interfaces. La dépendance ne va que dans **un seul sens** :

```
presentation  ──▶  domain  ◀──  data
   (UI)              (métier)        (impl)
```

## 1. Couches

### Domaine (`lib/domain`) — pur, aucun import Flutter/SDK tiers
- **entities/** : `ConversationMessage`, `CefrLevel` (+ `buildSystemPrompt`),
  `Scenario` (`kScenarios`).
- **repositories/** : interfaces (`ConversationRepository`, `UserRepository`).
  La couche domaine définit *ce dont elle a besoin*, pas *comment*.
- **usecases/** : un cas d'usage = une classe (`StartConversation`,
  `SendMessage`, `CorrectText`, `GetUserProfile`). La logique métier y est
  exposée de façon testable et isolée.

### Données (`lib/data`) — implémente les contrats du domaine
- **datasources/remote/** :
  - `LlmClient` : **interface** commune à tout fournisseur LLM.
  - `OpenAiClient` / `GeminiClient` : implémentent le streaming (SSE) et la
    correction. Facilement remplaçables / extensibles.
- **datasources/local/** : `ProfileLocalDataSource` (SharedPreferences) pour
  le niveau de l'utilisateur.
- **repositories/** : `*RepositoryImpl` orchestrant datasources → entités
  domaine.

### Présentation (`lib/presentation`) — UI
- **providers/** : graphe de dépendances Riverpod (assemblage des couches).
- **state/** : `ChatState` (immutable) + `ChatNotifier` (StateNotifier)
  qui pilote le streaming, l'historique et les corrections.
- **screens/** : `onboarding` → `home` → `conversation` (routage GoRouter).
- **widgets/** : `LevelSelector`, `MessageBubble`.

## 2. Flux de données (envoi d'un message)

```
TextField
  └─ ChatNotifier.send(text)
       ├─ ajoute ConversationMessage.user            [state]
       ├─ ajoute un placeholder assistant            [state]
       ├─ SendMessage(history, userText, level)
       │     └─ ConversationRepositoryImpl.sendMessageChunks
       │           └─ LlmClient.streamChat (SSE) ──▶ Stream<String>
       ├─ pour chaque chunk : maj du contenu du dernier message  [state]
       └─ CorrectText(userText) ──▶ correction affichée sous le message [state]
```

Le `ChatNotifier` est le **seul** propriétaire de l'état de l'écran. Les
widgets ne font que lire (`ref.watch`) et déclencher des actions.

## 3. Choix techniques

| Choix | Raison |
|-------|--------|
| **Riverpod** (StateNotifier) | État prévisible, providers = DI explicite, testable |
| **GoRouter** | Routage déclaratif simple, deep-links futurs |
| **LlmClient (interface)** | Changer de fournisseur sans toucher au reste |
| **Streaming SSE** | Réponse mot-à-mot = UX de chat naturelle |
| **SharedPreferences** | Persistance locale minimale du niveau |
| **Aucune génération de code** | Le projet compile après un simple `flutter pub get` |

## 4. Extensibilité

- **Nouveau fournisseur LLM** : implémenter `LlmClient`, brancher dans
  `providers.dart` (switch sur `LLM_PROVIDER`).
- **Nouveau cas d'usage** : ajouter une classe dans `domain/usecases` +
  son provider.
- **Backend maison** : remplacer `LlmClient` par un client HTTP vers ta
  propre API (même interface).
- **Tests** : `usecases` et `ChatNotifier` sont testables sans widget
  (injecter des fakes de repositories).

## 5. Gestion d'erreurs

- Échec réseau du LLM → `Exception` remontée dans `ChatState.error`
  (affichée en bas de l'écran), conversation non bloquée.
- Correction impossible → ignorée silencieusement (best-effort).
