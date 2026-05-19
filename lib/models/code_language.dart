/// Supported code languages for Blank question templates.
class CodeLanguage {
  const CodeLanguage({required this.id, required this.label});

  final String id;
  final String label;

  static const python = CodeLanguage(id: 'python', label: 'Python');
  static const java = CodeLanguage(id: 'java', label: 'Java');
  static const javascript = CodeLanguage(id: 'javascript', label: 'JavaScript');
  static const typescript = CodeLanguage(id: 'typescript', label: 'TypeScript');
  static const c = CodeLanguage(id: 'c', label: 'C');
  static const go = CodeLanguage(id: 'go', label: 'Go');
  static const kotlin = CodeLanguage(id: 'kotlin', label: 'Kotlin');

  static const defaultId = 'python';

  static const supported = <CodeLanguage>[
    python,
    java,
    javascript,
    typescript,
    c,
    go,
    kotlin,
  ];

  static const Set<String> supportedIds = {
    'python',
    'java',
    'javascript',
    'typescript',
    'c',
    'go',
    'kotlin',
  };

  static CodeLanguage? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final lang in supported) {
      if (lang.id == id) return lang;
    }
    return null;
  }

  static String normalize(String? id) {
    if (id != null && supportedIds.contains(id)) return id;
    return defaultId;
  }
}
