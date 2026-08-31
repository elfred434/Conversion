/// Fournisseurs LLM supportes (gratuits pour la plupart).
enum LlmProvider {
  openai,
  openrouter,
  gemini,
  groq,
  ollama,
  ovhcloud,
  huggingface,
}

class LlmProviderMeta {
  final String label;
  final String defaultBaseUrl;
  final String defaultModel;
  final bool isGemini;
  final String hint;
  const LlmProviderMeta({
    required this.label,
    required this.defaultBaseUrl,
    required this.defaultModel,
    this.isGemini = false,
    this.hint = '',
  });
}

const Map<LlmProvider, LlmProviderMeta> kLlmProviders = {
  LlmProvider.openai: LlmProviderMeta(
    label: 'OpenAI',
    defaultBaseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-4o-mini',
  ),
  LlmProvider.openrouter: LlmProviderMeta(
    label: 'OpenRouter',
    defaultBaseUrl: 'https://openrouter.ai/api/v1',
    defaultModel: 'google/gemma-2-9b-it:free',
    hint: 'Compte gratuit, nombreux modeles open-source.',
  ),
  LlmProvider.gemini: LlmProviderMeta(
    label: 'Google AI Studio (Gemini)',
    defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    defaultModel: 'gemini-2.0-flash',
    isGemini: true,
    hint: 'Clee Google AI Studio. Jusqu’a 1M tokens de contexte.',
  ),
  LlmProvider.groq: LlmProviderMeta(
    label: 'Groq',
    defaultBaseUrl: 'https://api.groq.com/openai/v1',
    defaultModel: 'llama-3.3-70b-versatile',
    hint: 'Tres rapide (Llama 3.3 70B).',
  ),
  LlmProvider.ollama: LlmProviderMeta(
    label: 'Ollama (local)',
    defaultBaseUrl: 'http://localhost:11434/v1',
    defaultModel: 'gemma2:2b',
    hint: 'Mode hors-ligne : demarre Ollama et pull le modele localement.',
  ),
  LlmProvider.ovhcloud: LlmProviderMeta(
    label: 'OVHcloud AI Endpoints',
    defaultBaseUrl: 'https://<region>.ai.endpoints.ai.cloud.ovh.net/v1/<modele>',
    defaultModel: 'Meta-Llama-3_3-70B-Instruct',
    hint: 'Renseigne l’URL complete fournie par OVHcloud (elle contient deja le modele).',
  ),
  LlmProvider.huggingface: LlmProviderMeta(
    label: 'Hugging Face',
    defaultBaseUrl: 'https://api-inference.huggingface.co/models/<modele>',
    defaultModel: 'meta-llama/Llama-3.3-70B-Instruct',
    hint: 'Renseigne l’URL du modele fournie par Hugging Face.',
  ),
};
