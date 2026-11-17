import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/models/event_notification_model.dart';
import 'package:oraculo/services/event_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Testes de Notificações de Eventos (24h de Antecedência)', () {
    test('parseDueDateTime converte corretamente dateKey e horário', () {
      final dt1 = EventNotificationService.parseDueDateTime('2026-11-20', '14:30');
      expect(dt1, isNotNull);
      expect(dt1!.year, equals(2026));
      expect(dt1.month, equals(11));
      expect(dt1.day, equals(20));
      expect(dt1.hour, equals(14));
      expect(dt1.minute, equals(30));

      // Sem horário deve assumir horário padrão das 09:00
      final dt2 = EventNotificationService.parseDueDateTime('2026-12-01', 'Sem horário');
      expect(dt2, isNotNull);
      expect(dt2!.year, equals(2026));
      expect(dt2.month, equals(12));
      expect(dt2.day, equals(1));
      expect(dt2.hour, equals(9));
      expect(dt2.minute, equals(0));

      // Formato inválido retorna null
      final dtInvalid = EventNotificationService.parseDueDateTime('data-invalida', '10:00');
      expect(dtInvalid, isNull);
    });

    test('isDueInNext24Hours identifica eventos com vencimento dentro de 24h', () {
      final now = DateTime.now();

      // Evento a 12 horas no futuro -> deve ser verdadeiro
      final eventIn12h = EventNotificationModel(
        id: 'notif_1',
        taskId: 'task_1',
        title: 'Simulado de Redação',
        time: '14:00',
        dateKey: '2026-11-17',
        category: 'Redação',
        dueDateTime: now.add(const Duration(hours: 12)),
        createdAt: now,
      );
      expect(eventIn12h.isDueInNext24Hours, isTrue);
      expect(eventIn12h.isPastDue, isFalse);

      // Evento a 23 horas e 30 minutos no futuro -> deve ser verdadeiro
      final eventIn23h = EventNotificationModel(
        id: 'notif_2',
        taskId: 'task_2',
        title: 'Revisão de Biologia',
        time: '09:00',
        dateKey: '2026-11-17',
        category: 'Ciências',
        dueDateTime: now.add(const Duration(hours: 23, minutes: 30)),
        createdAt: now,
      );
      expect(eventIn23h.isDueInNext24Hours, isTrue);

      // Evento a 26 horas no futuro -> NÃO deve notificar (ainda faltam mais de 24h)
      final eventIn26h = EventNotificationModel(
        id: 'notif_3',
        taskId: 'task_3',
        title: 'Entrega de Matemática',
        time: '18:00',
        dateKey: '2026-11-18',
        category: 'Exatas',
        dueDateTime: now.add(const Duration(hours: 26)),
        createdAt: now,
      );
      expect(eventIn26h.isDueInNext24Hours, isFalse);

      // Evento passado (1 hora atrás) -> NÃO deve notificar como futuro
      final eventPast = EventNotificationModel(
        id: 'notif_4',
        taskId: 'task_4',
        title: 'Reunião Passada',
        time: '10:00',
        dateKey: '2026-11-15',
        category: 'Geral',
        dueDateTime: now.subtract(const Duration(hours: 1)),
        createdAt: now,
      );
      expect(eventPast.isDueInNext24Hours, isFalse);
      expect(eventPast.isPastDue, isTrue);
    });

    test('remainingTimeFormatted formata corretamente horas e minutos restantes', () {
      final now = DateTime.now();

      final notif = EventNotificationModel(
        id: 'notif_time',
        taskId: 'task_time',
        title: 'Teste',
        time: '15:00',
        dateKey: '2026-11-17',
        category: 'Geral',
        dueDateTime: now.add(const Duration(hours: 5, minutes: 30, seconds: 5)),
        createdAt: now,
      );

      expect(notif.remainingTimeFormatted, contains('5h'));
      expect(notif.remainingTimeFormatted, contains('min'));
    });

    test('Serialização toJson e fromJson preserva todos os dados', () {
      final original = EventNotificationModel(
        id: 'notif_json',
        taskId: 'task_abc',
        title: 'Leitura Machado de Assis',
        time: '16:00',
        dateKey: '2026-11-20',
        category: 'Linguagens',
        dueDateTime: DateTime(2026, 11, 20, 16, 0),
        iconCodePoint: 58835,
        iconColorValue: 0xFFFFAB8C,
        createdAt: DateTime(2026, 11, 16, 10, 0),
        isDismissed: false,
      );

      final json = original.toJson();
      final restored = EventNotificationModel.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.taskId, equals(original.taskId));
      expect(restored.title, equals(original.title));
      expect(restored.time, equals(original.time));
      expect(restored.dateKey, equals(original.dateKey));
      expect(restored.category, equals(original.category));
      expect(restored.dueDateTime, equals(original.dueDateTime));
      expect(restored.iconCodePoint, equals(original.iconCodePoint));
      expect(restored.iconColorValue, equals(original.iconColorValue));
      expect(restored.isDismissed, equals(original.isDismissed));
    });

    test('EventNotificationService gerencia notificações e descarte', () async {
      final service = EventNotificationService.instance;
      await service.initialize();

      // Mock de notificação
      final notif = EventNotificationModel(
        id: 'notif_test_1',
        taskId: 'task_test_1',
        title: 'Evento Teste',
        time: '12:00',
        dateKey: '2026-11-17',
        category: 'Geral',
        dueDateTime: DateTime.now().add(const Duration(hours: 10)),
        createdAt: DateTime.now(),
      );

      service.activeNotificationsNotifier.value = [notif];
      expect(service.activeNotifications.length, equals(1));
      expect(service.activeNotifications.first.isDismissed, isFalse);

      // Descartar notificação
      await service.dismissNotification('notif_test_1');
      expect(service.activeNotifications.first.isDismissed, isTrue);

      // Remover por ID de tarefa
      service.removeNotificationForTask('task_test_1');
      expect(service.activeNotifications.isEmpty, isTrue);

      service.stopPeriodicCheck();
    });
  });
}
