import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/data/universal_books_catalog.dart';
import 'package:oraculo/data/universal_enem_questions.dart';
import 'package:oraculo/models/enem_question_model.dart';

void main() {
  group('Testes dos Simulados e Questões Modelo ENEM', () {
    test('Cada conteúdo do catálogo possui no mínimo 10 questões ENEM', () {
      expect(universalBooksCatalog.isNotEmpty, isTrue);

      for (final book in universalBooksCatalog) {
        final questions = UniversalEnemQuestions.getQuestionsForBook(book.id);
        expect(
          questions.length,
          greaterThanOrEqualTo(10),
          reason: 'Livro "${book.title}" (${book.id}) deve ter pelo menos 10 questões ENEM.',
        );
      }
    });

    test('Total de questões cadastradas é pelo menos 110 (11 conteúdos x 10 questões)', () {
      expect(UniversalEnemQuestions.totalQuestionsCount, greaterThanOrEqualTo(110));
    });

    test('Todas as questões possuem 5 alternativas e índice correto válido (0 a 4)', () {
      for (final book in universalBooksCatalog) {
        for (final q in book.questions) {
          expect(q.options.length, equals(5),
              reason: 'Questão ${q.number} do livro ${book.id} deve ter exatamente 5 alternativas (A, B, C, D, E).');
          expect(q.correctOptionIndex, inInclusiveRange(0, 4),
              reason: 'Índice de resposta da questão ${q.number} deve estar entre 0 e 4.');
          expect(q.correctLetter, isIn(['A', 'B', 'C', 'D', 'E']));
          expect(q.questionText.trim().isNotEmpty, isTrue);
          expect(q.explanation.trim().isNotEmpty, isTrue);
        }
      }
    });

    test('Questão 98 (Química - separação de misturas) da imagem do usuário está perfeitamente cadastrada', () {
      final quimicaQuestions = UniversalEnemQuestions.getQuestionsForBook('quimica-geral-organica');
      final q98 = quimicaQuestions.firstWhere((q) => q.number == 98);

      expect(q98.questionText, contains('A sequência dos procedimentos utilizados pelo pesquisador foi:'));
      expect(q98.options[0], equals('Filtração, decantação e extração.'));
      expect(q98.options[1], equals('Extração, filtração e centrifugação.'));
      expect(q98.options[2], equals('Destilação, filtração e precipitação.'));
      expect(q98.options[3], equals('Centrifugação, extração e decantação.'));
      expect(q98.options[4], equals('Precipitação, decantação e centrifugação.'));
      // Alternativa B (índice 1) é a correta
      expect(q98.correctOptionIndex, equals(1));
      expect(q98.correctLetter, equals('B'));
    });

    test('Serialização toMap e fromMap preserva todos os campos', () {
      const original = EnemQuestionModel(
        id: 'test-q1',
        number: 98,
        yearSource: 'ENEM 2022',
        contextText: 'Texto contexto teste',
        questionText: 'Comando da questão teste',
        options: ['Opção A', 'Opção B', 'Opção C', 'Opção D', 'Opção E'],
        correctOptionIndex: 2,
        explanation: 'Resolução explicativa teste',
      );

      final map = original.toMap();
      final reconstructed = EnemQuestionModel.fromMap(map);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.number, equals(original.number));
      expect(reconstructed.yearSource, equals(original.yearSource));
      expect(reconstructed.contextText, equals(original.contextText));
      expect(reconstructed.questionText, equals(original.questionText));
      expect(reconstructed.options, equals(original.options));
      expect(reconstructed.correctOptionIndex, equals(original.correctOptionIndex));
      expect(reconstructed.explanation, equals(original.explanation));
      expect(reconstructed.correctLetter, equals('C'));
    });
  });
}
