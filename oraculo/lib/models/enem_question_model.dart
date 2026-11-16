import 'dart:convert';

/// Modelo de Questão no Padrão Oficial do ENEM.
///
/// Segue o layout gráfico clássico dos cadernos de prova:
/// - Cabeçalho: "QUESTÃO XX" seguido de linha horizontal preta
/// - Texto de Apoio / Contextualização
/// - Comando da Questão
/// - 5 Alternativas identificadas por círculos pretos com letras brancas (A, B, C, D, E)
/// - Resolução comentada e gabarito oficial
class EnemQuestionModel {
  final String id;
  final int number;
  final String? yearSource;
  final String? contextText;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // 0=A, 1=B, 2=C, 3=D, 4=E
  final String explanation;

  const EnemQuestionModel({
    required this.id,
    required this.number,
    this.yearSource,
    this.contextText,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  /// Letra correspondente à resposta correta (A, B, C, D ou E)
  String get correctLetter {
    if (correctOptionIndex >= 0 && correctOptionIndex < 5) {
      return const ['A', 'B', 'C', 'D', 'E'][correctOptionIndex];
    }
    return '';
  }

  EnemQuestionModel copyWith({
    String? id,
    int? number,
    String? yearSource,
    String? contextText,
    String? questionText,
    List<String>? options,
    int? correctOptionIndex,
    String? explanation,
  }) {
    return EnemQuestionModel(
      id: id ?? this.id,
      number: number ?? this.number,
      yearSource: yearSource ?? this.yearSource,
      contextText: contextText ?? this.contextText,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'yearSource': yearSource,
      'contextText': contextText,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
    };
  }

  factory EnemQuestionModel.fromMap(Map<String, dynamic> map) {
    return EnemQuestionModel(
      id: map['id']?.toString() ?? '',
      number: (map['number'] is num)
          ? (map['number'] as num).toInt()
          : int.tryParse(map['number']?.toString() ?? '') ?? 1,
      yearSource: map['yearSource']?.toString(),
      contextText: map['contextText']?.toString(),
      questionText: map['questionText']?.toString() ?? '',
      options: (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctOptionIndex: (map['correctOptionIndex'] is num)
          ? (map['correctOptionIndex'] as num).toInt()
          : int.tryParse(map['correctOptionIndex']?.toString() ?? '') ?? 0,
      explanation: map['explanation']?.toString() ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory EnemQuestionModel.fromJson(String source) =>
      EnemQuestionModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Gera código Dart para serialização estática
  String toDartCode({String indent = '    '}) {
    final buffer = StringBuffer();
    buffer.writeln('${indent}EnemQuestionModel(');
    buffer.writeln("$indent  id: '$id',");
    buffer.writeln('$indent  number: $number,');
    if (yearSource != null && yearSource!.isNotEmpty) {
      buffer.writeln("$indent  yearSource: '${yearSource!.replaceAll("'", "\\'")}',");
    }
    if (contextText != null && contextText!.isNotEmpty) {
      buffer.writeln("$indent  contextText: r'''${contextText!.replaceAll("'''", r"\'\'\'")}''',");
    }
    buffer.writeln("$indent  questionText: r'''${questionText.replaceAll("'''", r"\'\'\'")}''',");
    buffer.writeln('$indent  options: const [');
    for (final opt in options) {
      buffer.writeln("$indent    r'''${opt.replaceAll("'''", r"\'\'\'")}''',");
    }
    buffer.writeln('$indent  ],');
    buffer.writeln('$indent  correctOptionIndex: $correctOptionIndex,');
    buffer.writeln("$indent  explanation: r'''${explanation.replaceAll("'''", r"\'\'\'")}''',");
    buffer.write('$indent)');
    return buffer.toString();
  }
}
