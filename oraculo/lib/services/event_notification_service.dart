import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_notification_model.dart';
import '../pages/dates_and_tasks.dart';
import '../widgets/event_notification_banner.dart';
import '../main.dart';

/// Serviço que monitora eventos salvos (locais e na nuvem) e exibe notificações
/// "pop up" quando um evento entra no período de 24 horas antes do vencimento.
class EventNotificationService {
  EventNotificationService._();
  static final EventNotificationService instance = EventNotificationService._();

  static const String _dismissedKey = 'oraculo_dismissed_notification_ids';
  static const String _localTasksKey = 'oraculo_local_tasks_data';

  Timer? _timer;
  OverlayEntry? _currentOverlayEntry;
  Timer? _autoDismissTimer;

  final Set<String> _dismissedNotificationIds = {};
  final Set<String> _shownNotificationIds = {};

  final ValueNotifier<List<EventNotificationModel>> activeNotificationsNotifier =
      ValueNotifier<List<EventNotificationModel>>([]);

  List<EventNotificationModel> get activeNotifications =>
      activeNotificationsNotifier.value;

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

  /// Inicializa o serviço, carrega descartadas e inicia o ciclo de verificação
  Future<void> initialize() async {
    await _loadDismissedIds();
    await checkUpcomingEvents();
    startPeriodicCheck();
  }

  /// Inicia timer periódico para verificar eventos a cada 30 segundos
  void startPeriodicCheck({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      checkUpcomingEvents();
    });
  }

  void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _loadDismissedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_dismissedKey) ?? [];
      _dismissedNotificationIds.addAll(list);
    } catch (e) {
      debugPrint('Erro ao carregar notificações descartadas: $e');
    }
  }

  Future<void> _saveDismissedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _dismissedKey,
        _dismissedNotificationIds.toList(),
      );
    } catch (e) {
      debugPrint('Erro ao salvar notificações descartadas: $e');
    }
  }

  /// Converte dateKey ("YYYY-MM-DD") e time ("HH:mm") em DateTime exato
  static DateTime? parseDueDateTime(String dateKey, String time) {
    try {
      final parts = dateKey.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      int hour = 9; // Padrão se for 'Sem horário'
      int minute = 0;

      if (time.contains(':')) {
        final tp = time.split(':');
        if (tp.length >= 2) {
          hour = int.tryParse(tp[0].trim()) ?? 9;
          minute = int.tryParse(tp[1].trim()) ?? 0;
        }
      }

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// Carrega todas as tarefas/eventos (locais e do Firestore) e verifica os que vencem em 24h
  Future<List<EventNotificationModel>> checkUpcomingEvents({
    BuildContext? context,
  }) async {
    final List<EventNotificationModel> found = [];
    final Set<String> processedTaskIds = {};

    // 1. Carrega tarefas locais do SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localTasksKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((dateKey, taskListRaw) {
            if (taskListRaw is List) {
              for (final t in taskListRaw) {
                if (t is Map) {
                  final map = Map<String, dynamic>.from(t);
                  final taskId = map['id']?.toString() ?? '';
                  final title = map['title']?.toString() ?? 'Evento';
                  final time = map['time']?.toString() ?? '';
                  final category = map['category']?.toString() ?? 'Geral';
                  final iconCode = (map['iconCodePoint'] as num?)?.toInt();
                  final iconColorVal = (map['iconColor'] as num?)?.toInt() ?? 0xFFFFAB8C;

                  final due = parseDueDateTime(dateKey, time);
                  if (due != null) {
                    final notif = EventNotificationModel(
                      id: 'notif_${taskId}_$dateKey',
                      taskId: taskId,
                      title: title,
                      time: time,
                      dateKey: dateKey,
                      category: category,
                      dueDateTime: due,
                      iconCodePoint: iconCode,
                      iconColorValue: iconColorVal,
                      createdAt: DateTime.now(),
                      isDismissed: _dismissedNotificationIds.contains('notif_${taskId}_$dateKey'),
                    );

                    if (notif.isDueInNext24Hours) {
                      found.add(notif);
                      if (taskId.isNotEmpty) processedTaskIds.add(taskId);
                    }
                  }
                }
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar eventos locais: $e');
    }

    // 2. Carrega tarefas da nuvem (se logado)
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user != null && firestore != null) {
      try {
        final snapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final taskId = doc.id;
          if (processedTaskIds.contains(taskId)) continue;

          final title = (data['title'] as String?)?.trim() ?? 'Evento';
          final time = (data['time'] as String?)?.trim() ?? '';
          final dateKey = (data['dateKey'] as String?)?.trim() ?? '';
          final category = (data['category'] as String?)?.trim() ?? 'Geral';
          final iconCode = (data['iconCodePoint'] as num?)?.toInt();
          final iconColorVal = (data['iconColor'] as num?)?.toInt() ?? 0xFFFFAB8C;

          final due = parseDueDateTime(dateKey, time);
          if (due != null) {
            final notif = EventNotificationModel(
              id: 'notif_${taskId}_$dateKey',
              taskId: taskId,
              title: title,
              time: time,
              dateKey: dateKey,
              category: category,
              dueDateTime: due,
              iconCodePoint: iconCode,
              iconColorValue: iconColorVal,
              createdAt: DateTime.now(),
              isDismissed: _dismissedNotificationIds.contains('notif_${taskId}_$dateKey'),
            );

            if (notif.isDueInNext24Hours) {
              found.add(notif);
              processedTaskIds.add(taskId);
            }
          }
        }
      } catch (e) {
        debugPrint('Erro ao verificar eventos do Firestore: $e');
      }
    }

    // Ordena do que vence mais cedo para o mais distante
    found.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));

    // Atualiza a lista observável
    activeNotificationsNotifier.value = found;

    // Dispara Pop-up se houver algum evento elegível que ainda não foi exibido nesta sessão
    EventNotificationModel? pendingToPop;
    for (final n in found) {
      if (!n.isDismissed && !_shownNotificationIds.contains(n.id)) {
        pendingToPop = n;
        break;
      }
    }

    if (pendingToPop != null) {
      _shownNotificationIds.add(pendingToPop.id);
      showPopupNotification(
        pendingToPop,
        context: (context != null && context.mounted) ? context : null,
      );
    }

    return found;
  }

  /// Exibe o Pop-up de notificação flutuante no topo da tela
  void showPopupNotification(
    EventNotificationModel notification, {
    BuildContext? context,
  }) {
    hideCurrentPopup();

    final targetContext = (context != null && context.mounted)
        ? context
        : OraculoApp.navigatorKey.currentContext;

    final overlayState = (targetContext != null && targetContext.mounted)
        ? Overlay.maybeOf(targetContext, rootOverlay: true)
        : null;

    if (overlayState == null) {
      debugPrint('OverlayState não disponível no momento para pop-up de notificação.');
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Align(
        alignment: Alignment.topCenter,
        child: EventNotificationBanner(
          notification: notification,
          onViewEvent: () {
            hideCurrentPopup();
            _openEventInCalendar(ctx, notification);
          },
          onDismiss: () {
            dismissNotification(notification.id);
            hideCurrentPopup();
          },
        ),
      ),
    );

    _currentOverlayEntry = entry;
    overlayState.insert(entry);

    // Auto-oculta após 9 segundos se o usuário não interagir
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(seconds: 9), () {
      hideCurrentPopup();
    });
  }

  /// Remove o pop-up atual da tela
  void hideCurrentPopup() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    if (_currentOverlayEntry != null) {
      try {
        _currentOverlayEntry!.remove();
      } catch (_) {}
      _currentOverlayEntry = null;
    }
  }

  /// Marca uma notificação como descartada e persiste
  Future<void> dismissNotification(String notificationId) async {
    _dismissedNotificationIds.add(notificationId);
    await _saveDismissedIds();

    // Atualiza a lista ativa
    final current = activeNotificationsNotifier.value;
    activeNotificationsNotifier.value = current
        .map((n) => n.id == notificationId ? n.copyWith(isDismissed: true) : n)
        .toList();
  }

  /// Remove notificações associadas a uma tarefa deletada
  void removeNotificationForTask(String taskId) {
    _shownNotificationIds.removeWhere((id) => id.contains(taskId));
    _dismissedNotificationIds.removeWhere((id) => id.contains(taskId));
    activeNotificationsNotifier.value = activeNotificationsNotifier.value
        .where((n) => n.taskId != taskId)
        .toList();
  }

  /// Abre a tela do calendário diretamente na data do evento
  void _openEventInCalendar(BuildContext context, EventNotificationModel notification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DatesAndTasksPage(
          initialDate: notification.dueDateTime,
        ),
      ),
    );
  }

  /// Abre modal/bottom sheet listando todas as notificações ativas (com vencimento em 24h)
  void showNotificationCenterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
            maxWidth: 550,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFFFFAB8C),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lembretes de Eventos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          'Eventos com vencimento nas próximas 24h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<List<EventNotificationModel>>(
                valueListenable: activeNotificationsNotifier,
                builder: (context, notifications, _) {
                  final validList = notifications.where((n) => n.isDueInNext24Hours).toList();

                  if (validList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 48,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tudo em dia!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Nenhum evento com vencimento nas próximas 24 horas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: validList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notif = validList[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: notif.iconColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  notif.icon,
                                  color: notif.iconColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${notif.dueLabel} • ${notif.remainingTimeFormatted}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFAB8C),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(modalContext);
                                  _openEventInCalendar(context, notif);
                                },
                                child: const Text(
                                  'Ver',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
