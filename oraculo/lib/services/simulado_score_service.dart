import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/simulado_score_model.dart';

/// Serviço responsável pelo gerenciamento e persistência das pontuações dos
/// Simulados ENEM em tabela de banco de dados (Cloud Firestore + Tabela Local SharedPreferences).
class SimuladoScoreService {
  SimuladoScoreService._();
  static final SimuladoScoreService instance = SimuladoScoreService._();

  static const String _localStorageKey = 'oraculo_simulado_scores_table_v1';

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final ValueNotifier<List<SimuladoScoreModel>> scoresNotifier =
      ValueNotifier<List<SimuladoScoreModel>>([]);

  List<SimuladoScoreModel> get scores => scoresNotifier.value;

  /// Inicializa o serviço carregando registros da tabela local e da nuvem
  Future<void> initialize() async {
    await _loadFromLocalTable();
    await _syncWithFirestore();
  }

  /// Salva uma nova pontuação no banco de dados
  Future<SimuladoScoreModel> recordScore({
    required String bookId,
    required String bookTitle,
    required String category,
    required int score,
    required int totalQuestions,
    required int answeredCount,
    required Map<int, int> userAnswers,
  }) async {
    final user = _auth?.currentUser;
    final userId = user?.uid ?? 'guest_user';
    final percentage = totalQuestions > 0
        ? ((score / totalQuestions) * 100).toDouble()
        : 0.0;

    final id = 'sim_${DateTime.now().millisecondsSinceEpoch}';

    final scoreRecord = SimuladoScoreModel(
      id: id,
      userId: userId,
      bookId: bookId,
      bookTitle: bookTitle,
      category: category,
      score: score,
      totalQuestions: totalQuestions,
      percentage: percentage,
      answeredCount: answeredCount,
      timestamp: DateTime.now(),
      userAnswers: userAnswers,
    );

    // 1. Atualiza a lista em memória
    final updatedList = List<SimuladoScoreModel>.from(scoresNotifier.value)
      ..insert(0, scoreRecord);
    scoresNotifier.value = updatedList;

    // 2. Grava na tabela local (SharedPreferences)
    await _saveToLocalTable(updatedList);

    // 3. Grava no Cloud Firestore se houver usuário autenticado
    if (user != null && _firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(user.uid)
            .collection('simulado_scores')
            .doc(id)
            .set(scoreRecord.toMap());
      } catch (e) {
        debugPrint('SimuladoScoreService: Erro ao sincronizar com Firestore: $e');
      }
    }

    return scoreRecord;
  }

  /// Retorna o melhor score registrado para um determinado livro
  SimuladoScoreModel? getBestScoreForBook(String bookId) {
    final bookScores = scores.where((s) => s.bookId == bookId).toList();
    if (bookScores.isEmpty) return null;
    bookScores.sort((a, b) => b.score.compareTo(a.score));
    return bookScores.first;
  }

  /// Retorna o score mais recente registrado para um determinado livro
  SimuladoScoreModel? getLatestScoreForBook(String bookId) {
    final bookScores = scores.where((s) => s.bookId == bookId).toList();
    if (bookScores.isEmpty) return null;
    bookScores.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return bookScores.first;
  }

  /// Retorna todos os scores registrados para um livro
  List<SimuladoScoreModel> getScoresForBook(String bookId) {
    return scores.where((s) => s.bookId == bookId).toList();
  }

  // ==========================================================
  // PERSISTÊNCIA NA TABELA LOCAL (JSON STORE)
  // ==========================================================

  Future<void> _loadFromLocalTable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_localStorageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final list = decoded
            .map((item) => SimuladoScoreModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
        scoresNotifier.value = list;
      }
    } catch (e) {
      debugPrint('SimuladoScoreService: Erro ao carregar tabela local: $e');
    }
  }

  Future<void> _saveToLocalTable(List<SimuladoScoreModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = list.map((item) => item.toMap()).toList();
      await prefs.setString(_localStorageKey, jsonEncode(rawList));
    } catch (e) {
      debugPrint('SimuladoScoreService: Erro ao salvar tabela local: $e');
    }
  }

  Future<void> _syncWithFirestore() async {
    final user = _auth?.currentUser;
    if (user == null || _firestore == null) return;

    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(user.uid)
          .collection('simulado_scores')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firestoreScores = snapshot.docs
            .map((doc) => SimuladoScoreModel.fromFirestore(doc))
            .toList();

        // Mescla com locais garantindo unicidade por id
        final Map<String, SimuladoScoreModel> map = {};
        for (final item in scoresNotifier.value) {
          map[item.id] = item;
        }
        for (final item in firestoreScores) {
          map[item.id] = item;
        }

        final merged = map.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        scoresNotifier.value = merged;
        await _saveToLocalTable(merged);
      }
    } catch (e) {
      debugPrint('SimuladoScoreService: Sincronização em segundo plano: $e');
    }
  }
}
