import 'package:flutter/material.dart';

/// Modelo de notificação para eventos e tarefas com vencimento próximo (24h de antecedência).
class EventNotificationModel {
  final String id;
  final String taskId;
  final String title;
  final String time;
  final String dateKey; // Formato YYYY-MM-DD
  final String category;
  final DateTime dueDateTime;
  final int? iconCodePoint;
  final int iconColorValue;
  final DateTime createdAt;
  final bool isDismissed;

  const EventNotificationModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.time,
    required this.dateKey,
    required this.category,
    required this.dueDateTime,
    this.iconCodePoint,
    this.iconColorValue = 0xFFFFAB8C,
    required this.createdAt,
    this.isDismissed = false,
  });

  /// Tempo restante até o vencimento do evento
  Duration get timeRemaining => dueDateTime.difference(DateTime.now());

  /// Retorna verdadeiro se o evento vence dentro das próximas 24 horas (e ainda não passou)
  bool get isDueInNext24Hours {
    final diff = timeRemaining;
    return diff > Duration.zero && diff <= const Duration(hours: 24);
  }

  /// Retorna verdadeiro se já passou da data/hora de vencimento
  bool get isPastDue => timeRemaining <= Duration.zero;

  /// Texto amigável indicando o tempo restante (ex: "Faltam 18h", "Faltam 45 min")
  String get remainingTimeFormatted {
    final diff = timeRemaining;
    if (diff <= Duration.zero) return 'Venceu agora';

    final totalHours = diff.inHours;
    final totalMinutes = diff.inMinutes;

    if (totalHours > 0) {
      final remMinutes = totalMinutes % 60;
      if (remMinutes > 0) {
        return 'Faltam ${totalHours}h e ${remMinutes}min';
      }
      return 'Faltam ${totalHours}h';
    }
    return 'Faltam ${totalMinutes}min';
  }

  /// Rótulo descritivo da data/horário (ex: "Hoje às 15:30", "Amanhã às 09:00")
  String get dueLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day);
    final dayDiff = eventDay.difference(today).inDays;

    final formattedTime = time.isNotEmpty && time != 'Sem horário'
        ? 'às $time'
        : '(dia todo)';

    if (dayDiff == 0) {
      return 'Hoje $formattedTime';
    } else if (dayDiff == 1) {
      return 'Amanhã $formattedTime';
    } else {
      final dayStr = dueDateTime.day.toString().padLeft(2, '0');
      final monthStr = dueDateTime.month.toString().padLeft(2, '0');
      return '$dayStr/$monthStr $formattedTime';
    }
  }

  IconData get icon {
    if (iconCodePoint != null) {
      if (iconCodePoint == Icons.article_rounded.codePoint) return Icons.article_rounded;
      if (iconCodePoint == Icons.menu_book_rounded.codePoint) return Icons.menu_book_rounded;
      if (iconCodePoint == Icons.functions_rounded.codePoint) return Icons.functions_rounded;
      if (iconCodePoint == Icons.groups_rounded.codePoint) return Icons.groups_rounded;
      if (iconCodePoint == Icons.event_note_rounded.codePoint) return Icons.event_note_rounded;
      // ignore: non_const_argument_for_const_parameter
      return IconData(iconCodePoint!, fontFamily: 'MaterialIcons');
    }
    return Icons.event_note_rounded;
  }

  Color get iconColor => Color(iconColorValue);

  EventNotificationModel copyWith({
    bool? isDismissed,
  }) {
    return EventNotificationModel(
      id: id,
      taskId: taskId,
      title: title,
      time: time,
      dateKey: dateKey,
      category: category,
      dueDateTime: dueDateTime,
      iconCodePoint: iconCodePoint,
      iconColorValue: iconColorValue,
      createdAt: createdAt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'time': time,
      'dateKey': dateKey,
      'category': category,
      'dueDateTime': dueDateTime.toIso8601String(),
      'iconCodePoint': iconCodePoint,
      'iconColorValue': iconColorValue,
      'createdAt': createdAt.toIso8601String(),
      'isDismissed': isDismissed,
    };
  }

  factory EventNotificationModel.fromJson(Map<String, dynamic> json) {
    return EventNotificationModel(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      time: json['time'] as String? ?? '',
      dateKey: json['dateKey'] as String? ?? '',
      category: json['category'] as String? ?? 'Geral',
      dueDateTime: json['dueDateTime'] != null
          ? DateTime.tryParse(json['dueDateTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      iconCodePoint: (json['iconCodePoint'] as num?)?.toInt(),
      iconColorValue: (json['iconColorValue'] as num?)?.toInt() ?? 0xFFFFAB8C,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isDismissed: json['isDismissed'] as bool? ?? false,
    );
  }
}
