import '../models/enem_question_model.dart';
import 'questions/ciencias_questions.dart';
import 'questions/humanas_questions.dart';
import 'questions/linguagens_questions.dart';
import 'questions/matematica_questions.dart';
import 'questions/redacao_questions.dart';

/// Catálogo central de simulados e questões no modelo ENEM
/// organizado por livro / conteúdo do Oráculo.
///
/// Cada material possui no mínimo 10 questões rigorosamente alinhadas
/// ao padrão gráfico e conceitual da matriz de referência do ENEM.
class UniversalEnemQuestions {
  UniversalEnemQuestions._();

  static final Map<String, List<EnemQuestionModel>> _catalog = {
    // Redação
    'redacao-nota-1000': redacaoNota1000Questions,
    'estrutura-argumentativa': estruturaArgumentativaQuestions,

    // Matemática
    'matematica-e-funcoes': matematicaEFuncoesQuestions,
    'geometria-espacial': geometriaEspacialQuestions,

    // Linguagens
    'literatura-e-classicos': literaturaEClassicosQuestions,
    'gramatica-e-interpretacao': gramaticaEInterpretacaoQuestions,

    // Ciências da Natureza
    'fisica-mecanica-optica': fisicaMecanicaOpticaQuestions,
    'quimica-geral-organica': quimicaGeralOrganicaQuestions,
    'biologia-celular-genetica': biologiaCelularGeneticaQuestions,

    // Ciências Humanas
    'historia-do-brasil': historiaDoBrasilQuestions,
    'filosofia-e-sociologia': filosofiaESociologiaQuestions,
    'livro-1793723493857': historiaDaArteQuestions,
    'historia-da-arte': historiaDaArteQuestions,
  };

  /// Retorna as questões ENEM associadas ao livro pelo seu ID.
  /// Se o livro for um material customizado ou novo sem questões específicas,
  /// retorna uma lista vazia ou questões pertinentes da mesma categoria.
  static List<EnemQuestionModel> getQuestionsForBook(String bookId) {
    return _catalog[bookId] ?? const [];
  }

  /// Retorna todos os IDs de livros que possuem questões cadastradas
  static List<String> get availableBookIds => _catalog.keys.toList();

  /// Total de questões catalogadas no sistema
  static int get totalQuestionsCount {
    var count = 0;
    for (final list in _catalog.values) {
      count += list.length;
    }
    return count;
  }
}
