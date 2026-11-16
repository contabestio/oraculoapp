import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de registro de pontuação de Simulado ENEM salvo no banco de dados.
class SimuladoScoreModel {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String category;
  final int score;
  final int totalQuestions;
  final double percentage;
  final int answeredCount;
  final DateTime timestamp;
  final Map<int, int> userAnswers;

  const SimuladoScoreModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.answeredCount,
    required this.timestamp,
    this.userAnswers = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'answeredCount': answeredCount,
      'timestamp': timestamp.toIso8601String(),
      'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  factory SimuladoScoreModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    Map<int, int> parseAnswers(dynamic raw) {
      if (raw is Map) {
        final result = <int, int>{};
        raw.forEach((k, v) {
          final keyInt = int.tryParse(k.toString());
          final valInt = int.tryParse(v.toString());
          if (keyInt != null && valInt != null) {
            result[keyInt] = valInt;
          }
        });
        return result;
      }
      return {};
    }

    return SimuladoScoreModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? 'anonymous',
      bookId: map['bookId']?.toString() ?? '',
      bookTitle: map['bookTitle']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      score: (map['score'] is num) ? (map['score'] as num).toInt() : 0,
      totalQuestions: (map['totalQuestions'] is num)
          ? (map['totalQuestions'] as num).toInt()
          : 10,
      percentage: (map['percentage'] is num)
          ? (map['percentage'] as num).toDouble()
          : 0.0,
      answeredCount: (map['answeredCount'] is num)
          ? (map['answeredCount'] as num).toInt()
          : 0,
      timestamp: parseDate(map['timestamp']),
      userAnswers: parseAnswers(map['userAnswers']),
    );
  }

  factory SimuladoScoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    data['id'] = doc.id;
    return SimuladoScoreModel.fromMap(data);
  }
}
