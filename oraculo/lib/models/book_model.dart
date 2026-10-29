import 'dart:convert';

/// =========================================================================
/// CAPAS REUTILIZÁVEIS PRONTAS PARA COPIAR E COLAR
/// =========================================================================
class BookCovers {
  static const String redacao =
      'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&q=80';
  static const String cadernos =
      'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&q=80';
  static const String matematica =
      'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80';
  static const String geometria =
      'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80';
  static const String literatura =
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80';
  static const String linguagens =
      'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80';
  static const String fisica =
      'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400&q=80';
  static const String quimica =
      'https://images.unsplash.com/photo-1603126857599-f6e157fa2fe6?w=400&q=80';
  static const String biologia =
      'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=400&q=80';
  static const String historia =
      'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80';
  static const String filosofia =
      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400&q=80';
  static const String tecnologia =
      'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400&q=80';
}

/// =========================================================================
/// CATEGORIAS PADRÃO DO ORÁCULO
/// =========================================================================
class BookCategories {
  static const String redacao = 'Redação';
  static const String matematica = 'Matemática';
  static const String linguagens = 'Linguagens';
  static const String ciencias = 'Ciências';
  static const String humanas = 'Humanas';
  static const String atualidades = 'Atualidades';
}

/// =========================================================================
/// COMPONENTE 1: CAPÍTULO / SEÇÃO DO LIVRO
/// =========================================================================
class BookSectionModel {
  final String id;
  final String title;
  final String content;
  final List<String> keyTakeaways;
  final String? studyTip;

  const BookSectionModel({
    required this.id,
    required this.title,
    required this.content,
    this.keyTakeaways = const [],
    this.studyTip,
  });

  /// Construtor simplificado para adicionar capítulos rapidamente:
  /// ```dart
  /// BookSectionModel.simple(
  ///   title: '1. Introdução',
  ///   content: 'Texto aqui...',
  ///   studyTip: 'Dica de ouro...',
  /// )
  /// ```
  factory BookSectionModel.simple({
    String? id,
    required String title,
    required String content,
    String? studyTip,
    List<String> keyTakeaways = const [],
  }) {
    return BookSectionModel(
      id: id ?? 'sec-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      studyTip: studyTip,
      keyTakeaways: keyTakeaways,
    );
  }

  BookSectionModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? keyTakeaways,
    String? studyTip,
  }) {
    return BookSectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      studyTip: studyTip ?? this.studyTip,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'keyTakeaways': keyTakeaways,
      'studyTip': studyTip,
    };
  }

  factory BookSectionModel.fromMap(Map<String, dynamic> map) {
    return BookSectionModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      keyTakeaways: (map['keyTakeaways'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      studyTip: map['studyTip']?.toString(),
    );
  }

  /// Gera código Dart pronto para copiar e colar
  String toDartCode({String indent = '    '}) {
    final buffer = StringBuffer();
    buffer.writeln('${indent}BookSectionModel(');
    buffer.writeln("$indent  id: '$id',");
    buffer.writeln("$indent  title: '${title.replaceAll("'", "\\'")}',");
    buffer.writeln("$indent  content: r'''${content.replaceAll("'''", r"\'\'\'")}''',");
    if (keyTakeaways.isNotEmpty) {
      final items = keyTakeaways.map((k) => "'${k.replaceAll("'", "\\'")}'").join(', ');
      buffer.writeln('$indent  keyTakeaways: const [$items],');
    }
    if (studyTip != null && studyTip!.isNotEmpty) {
      buffer.writeln("$indent  studyTip: '${studyTip!.replaceAll("'", "\\'")}',");
    }
    buffer.write('$indent)');
    return buffer.toString();
  }
}

/// =========================================================================
/// COMPONENTE 2: O LIVRO / MATERIAL COMPLETO
/// =========================================================================
class BookModel {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String description;
  final int readTimeMinutes;
  final String author;
  final List<String> tags;
  final List<BookSectionModel> sections;
  final bool isCustom;

  const BookModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    this.description = '',
    this.readTimeMinutes = 10,
    this.author = 'Equipe Oráculo',
    this.tags = const [],
    this.sections = const [],
    this.isCustom = false,
  });

  /// Construtor ultra-rápido para criar um livro em poucas linhas:
  /// ```dart
  /// BookModel.quick(
  ///   id: 'meu-livro',
  ///   title: 'Funções Exponenciais',
  ///   category: BookCategories.matematica,
  ///   imageUrl: BookCovers.matematica,
  ///   content: 'Conteúdo explicativo da matéria...',
  /// )
  /// ```
  factory BookModel.quick({
    required String id,
    required String title,
    required String category,
    String? imageUrl,
    String description = '',
    int readTimeMinutes = 10,
    String author = 'Equipe Oráculo',
    List<String> tags = const [],
    required String content,
    String? studyTip,
    List<String> keyTakeaways = const [],
  }) {
    return BookModel(
      id: id,
      title: title,
      category: category,
      imageUrl: imageUrl ?? BookCovers.cadernos,
      description: description,
      readTimeMinutes: readTimeMinutes,
      author: author,
      tags: tags,
      sections: [
        BookSectionModel(
          id: '$id-cap-1',
          title: '1. Conteúdo Principal',
          content: content,
          studyTip: studyTip,
          keyTakeaways: keyTakeaways,
        ),
      ],
    );
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    String? description,
    int? readTimeMinutes,
    String? author,
    List<String>? tags,
    List<BookSectionModel>? sections,
    bool? isCustom,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      sections: sections ?? this.sections,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'readTimeMinutes': readTimeMinutes,
      'author': author,
      'tags': tags,
      'sections': sections.map((s) => s.toMap()).toList(),
      'isCustom': isCustom,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Geral',
      imageUrl: map['imageUrl']?.toString() ?? map['image']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      readTimeMinutes: (map['readTimeMinutes'] is num)
          ? (map['readTimeMinutes'] as num).toInt()
          : int.tryParse(map['readTimeMinutes']?.toString() ?? '') ?? 10,
      author: map['author']?.toString() ?? 'Equipe Oráculo',
      tags: (map['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sections: (map['sections'] as List<dynamic>?)
              ?.map((s) => BookSectionModel.fromMap(Map<String, dynamic>.from(s as Map)))
              .toList() ??
          const [],
      isCustom: map['isCustom'] == true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory BookModel.fromJson(String source) =>
      BookModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Gera código Dart pronto para colar em universal_books_catalog.dart
  String toDartCode() {
    final buffer = StringBuffer();
    buffer.writeln('BookModel(');
    buffer.writeln("  id: '$id',");
    buffer.writeln("  title: '${title.replaceAll("'", "\\'")}',");
    buffer.writeln("  category: '${category.replaceAll("'", "\\'")}',");
    buffer.writeln("  imageUrl: '$imageUrl',");
    buffer.writeln("  description: r'''${description.replaceAll("'''", r"\'\'\'")}''',");
    buffer.writeln('  readTimeMinutes: $readTimeMinutes,');
    buffer.writeln("  author: '${author.replaceAll("'", "\\'")}',");
    if (tags.isNotEmpty) {
      final tagsStr = tags.map((t) => "'${t.replaceAll("'", "\\'")}'").join(', ');
      buffer.writeln('  tags: const [$tagsStr],');
    }
    if (sections.isNotEmpty) {
      buffer.writeln('  sections: [');
      for (final s in sections) {
        buffer.writeln('${s.toDartCode(indent: '    ')},');
      }
      buffer.writeln('  ],');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// =========================================================================
/// TEMPLATES PRONTOS EM TEXTO PARA COPIAR E COLAR
/// =========================================================================
class BookTemplates {
  /// Template completo de um livro para copiar e colar
  static const String fullBookTemplate = '''
BookModel(
  id: 'meu-novo-livro',
  title: 'Título do Material',
  category: BookCategories.redacao, // BookCategories: redacao, matematica, linguagens, ciencias, humanas...
  imageUrl: BookCovers.redacao,      // BookCovers: redacao, matematica, literatura, fisica, historia...
  description: 'Breve resumo do assunto que o estudante vai aprender neste material.',
  readTimeMinutes: 15,
  author: 'Equipe Oráculo',
  tags: const ['enem', 'vestibular', 'resumo'],
  sections: [
    BookSectionModel(
      id: 'cap-1',
      title: '1. Introdução e Conceitos Principais',
      content: \'\'\'
Escreva aqui o conteúdo da aula ou matéria.
Pode usar quebras de linha normais e marcadores:
• Ponto importante 1
• Ponto importante 2
• Exemplo prático
\'\'\',
      keyTakeaways: const [
        'Conceito chave que sempre cai na prova',
        'Fórmula ou regra prática para lembrar',
      ],
      studyTip: 'Dica de ouro do professor ou pegadinha comum para ficar atento!',
    ),
  ],
),
''';

  /// Template de um capítulo para adicionar dentro de sections: [...]
  static const String sectionTemplate = '''
BookSectionModel(
  id: 'cap-2',
  title: '2. Título do Novo Capítulo',
  content: \'\'\'
Conteúdo do texto explicativo deste capítulo...
• Detalhe A
• Detalhe B
\'\'\',
  keyTakeaways: const [
    'Ponto principal 1',
    'Ponto principal 2',
  ],
  studyTip: 'Dica prática para vestibulares e provas.',
),
''';

  /// Template minimalista em 5 linhas
  static const String quickBookTemplate = '''
BookModel.quick(
  id: 'livro-rapido-1',
  title: 'Título Rápido',
  category: BookCategories.matematica,
  imageUrl: BookCovers.matematica,
  description: 'Resumo rápido do tema.',
  content: \'\'\'Texto explicativo completo aqui...\'\'\',
  studyTip: 'Dica importante!',
  keyTakeaways: const ['Ponto 1', 'Ponto 2'],
),
''';
}
