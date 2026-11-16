import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/models/simulado_score_model.dart';
import 'package:oraculo/services/simulado_score_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Testes da Tabela de Pontuações de Simulados no Banco de Dados', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      SimuladoScoreService.instance.scoresNotifier.value = [];
    });

    test('SimuladoScoreModel serializa e desserializa corretamente', () {
      final now = DateTime.now();
      final score = SimuladoScoreModel(
        id: 'test-rec-1',
        userId: 'user-123',
        bookId: 'quimica-geral-organica',
        bookTitle: 'Química Geral & Orgânica',
        category: 'Ciências',
        score: 8,
        totalQuestions: 10,
        percentage: 80.0,
        answeredCount: 10,
        timestamp: now,
        userAnswers: {0: 1, 1: 2, 2: 0},
      );

      final map = score.toMap();
      final reconstructed = SimuladoScoreModel.fromMap(map);

      expect(reconstructed.id, equals('test-rec-1'));
      expect(reconstructed.userId, equals('user-123'));
      expect(reconstructed.bookId, equals('quimica-geral-organica'));
      expect(reconstructed.bookTitle, equals('Química Geral & Orgânica'));
      expect(reconstructed.score, equals(8));
      expect(reconstructed.totalQuestions, equals(10));
      expect(reconstructed.percentage, equals(80.0));
      expect(reconstructed.answeredCount, equals(10));
      expect(reconstructed.userAnswers[0], equals(1));
      expect(reconstructed.userAnswers[1], equals(2));
      expect(reconstructed.userAnswers[2], equals(0));
    });

    test('recordScore grava na tabela e atualiza o scoresNotifier', () async {
      await SimuladoScoreService.instance.initialize();

      expect(SimuladoScoreService.instance.scores.isEmpty, isTrue);

      final saved = await SimuladoScoreService.instance.recordScore(
        bookId: 'matematica-e-funcoes',
        bookTitle: 'Matemática e Funções',
        category: 'Matemática',
        score: 7,
        totalQuestions: 10,
        answeredCount: 10,
        userAnswers: {0: 1, 1: 0},
      );

      expect(saved.score, equals(7));
      expect(saved.percentage, equals(70.0));
      expect(SimuladoScoreService.instance.scores.length, equals(1));
      expect(SimuladoScoreService.instance.scores.first.id, equals(saved.id));

      // Grava uma segunda tentativa melhor
      await SimuladoScoreService.instance.recordScore(
        bookId: 'matematica-e-funcoes',
        bookTitle: 'Matemática e Funções',
        category: 'Matemática',
        score: 9,
        totalQuestions: 10,
        answeredCount: 10,
        userAnswers: {0: 1, 1: 1},
      );

      expect(SimuladoScoreService.instance.scores.length, equals(2));

      final best = SimuladoScoreService.instance.getBestScoreForBook('matematica-e-funcoes');
      expect(best, isNotNull);
      expect(best!.score, equals(9));
      expect(best.percentage, equals(90.0));

      final latest = SimuladoScoreService.instance.getLatestScoreForBook('matematica-e-funcoes');
      expect(latest, isNotNull);
      expect(latest!.score, equals(9));
    });

    test('Pontuações persistem na tabela local recarregada', () async {
      await SimuladoScoreService.instance.recordScore(
        bookId: 'redacao-nota-1000',
        bookTitle: 'Redação Nota 1000',
        category: 'Redação',
        score: 10,
        totalQuestions: 10,
        answeredCount: 10,
        userAnswers: {},
      );

      // Limpa memória para simular reinício do app
      SimuladoScoreService.instance.scoresNotifier.value = [];
      expect(SimuladoScoreService.instance.scores.isEmpty, isTrue);

      // Re-inicializa para carregar do SharedPreferences
      await SimuladoScoreService.instance.initialize();
      expect(SimuladoScoreService.instance.scores.length, equals(1));
      expect(SimuladoScoreService.instance.scores.first.bookId, equals('redacao-nota-1000'));
      expect(SimuladoScoreService.instance.scores.first.score, equals(10));
    });
  });
}
