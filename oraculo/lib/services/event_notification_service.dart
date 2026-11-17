import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_notification_model.dart';
import '../pages/dates_and_tasks.dart';
import '../widgets/event_notification_banner.dart';
import '../main.dart';

/// Serviço que monitora eventos salvos (locais e na nuvem), dispara notificações
/// nativas no sistema Android e exibe alertas "pop up" quando um evento entra
/// no período de 24 horas antes do vencimento.
class EventNotificationService {
  EventNotificationService._();
  static final EventNotificationService instance = EventNotificationService._();

  static const MethodChannel _androidChannel =
      MethodChannel('com.example.oraculo/notifications');

  static const String _dismissedKey = 'oraculo_dismissed_notification_ids';
  static const String _androidNotifiedKey = 'oraculo_android_notified_ids';
  static const String _localTasksKey = 'oraculo_local_tasks_data';

  Timer? _timer;
  OverlayEntry? _currentOverlayEntry;
  Timer? _autoDismissTimer;

  final Set<String> _dismissedNotificationIds = {};
  final Set<String> _shownNotificationIds = {};
  final Set<String> _androidNotifiedIds = {};

  final ValueNotifier<List<EventNotificationModel>> activeNotificationsNotifier =
      ValueNotifier<List<EventNotificationModel>>([]);

  List<EventNotificationModel> get activeNotifications =>
      activeNotificationsNotifier.value;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

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

  /// Gera um ID numérico positivo determinístico para o NotificationManager/AlarmManager do Android
  static int _computeAndroidId(String key) {
    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = 0x1fffffff & (hash + key.codeUnitAt(i));
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= (hash >> 6);
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= (hash >> 11);
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    return (hash & 0x7fffffff) == 0 ? 1 : (hash & 0x7fffffff);
  }

  /// Inicializa o serviço, solicita permissão no Android, carrega estado e inicia o ciclo de verificação
  Future<void> initialize() async {
    await _loadPersistedIds();
    await requestAndroidNotificationPermission();
    await checkUpcomingEvents();
    startPeriodicCheck();
  }

  /// Solicita permissão de notificação nativa no Android 13+ (API 33+)
  Future<void> requestAndroidNotificationPermission() async {
    if (!_isAndroid) return;
    try {
      await _androidChannel.invokeMethod('requestPermission');
    } catch (e) {
      debugPrint('Erro ao solicitar permissão de notificação no Android: $e');
    }
  }

  /// Exibe uma notificação imediata na barra de status / heads-up do Android
  Future<void> showAndroidNotification({
    required int id,
    required String title,
    required String body,
    String? dateKey,
  }) async {
    if (!_isAndroid) return;
    try {
      await _androidChannel.invokeMethod('showNotification', {
        'id': id,
        'title': title,
        'body': body,
        'dateKey': dateKey,
      });
    } catch (e) {
      debugPrint('Erro ao exibir notificação no Android: $e');
    }
  }

  /// Agenda um alarme nativo no Android para disparar a notificação no horário do evento
  Future<void> scheduleAndroidNotification({
    required int id,
    required String title,
    required String body,
    required DateTime triggerAt,
    String? dateKey,
  }) async {
    if (!_isAndroid) return;
    if (triggerAt.isBefore(DateTime.now())) return;
    try {
      await _androidChannel.invokeMethod('scheduleNotification', {
        'id': id,
        'title': title,
        'body': body,
        'triggerAtMillis': triggerAt.millisecondsSinceEpoch,
        'dateKey': dateKey,
      });
    } catch (e) {
      debugPrint('Erro ao agendar notificação no Android: $e');
    }
  }

  /// Cancela uma notificação/alarme nativo no Android
  Future<void> cancelAndroidNotification(int id) async {
    if (!_isAndroid) return;
    try {
      await _androidChannel.invokeMethod('cancelNotification', {'id': id});
    } catch (e) {
      debugPrint('Erro ao cancelar notificação no Android: $e');
    }
  }

  /// Agenda todos os lembretes nativos do Android para um evento futuro (24h antes, 1h antes e no horário exato)
  Future<void> _scheduleEventAlarms({
    required String taskId,
    required String title,
    required String time,
    required String dateKey,
    required String category,
    required DateTime dueDateTime,
  }) async {
    if (!_isAndroid) return;
    final now = DateTime.now();
    final timeDesc = (time.isNotEmpty && time != 'Sem horário')
        ? 'às $time'
        : '(dia todo)';

    // 1. Lembrete 24 horas antes
    final rem24h = dueDateTime.subtract(const Duration(hours: 24));
    if (rem24h.isAfter(now)) {
      await scheduleAndroidNotification(
        id: _computeAndroidId('rem24_${taskId}_$dateKey'),
        title: '⏰ Amanhã: $title',
        body: 'Seu evento ($category) está marcado para amanhã $timeDesc.',
        triggerAt: rem24h,
        dateKey: dateKey,
      );
    }

    // 2. Lembrete 1 hora antes
    final rem1h = dueDateTime.subtract(const Duration(hours: 1));
    if (rem1h.isAfter(now)) {
      await scheduleAndroidNotification(
        id: _computeAndroidId('rem1h_${taskId}_$dateKey'),
        title: '⏳ Falta 1 hora: $title',
        body: 'Prepare-se! Seu evento ($category) começa $timeDesc.',
        triggerAt: rem1h,
        dateKey: dateKey,
      );
    }

    // 3. Notificação no horário exato do evento
    if (dueDateTime.isAfter(now)) {
      await scheduleAndroidNotification(
        id: _computeAndroidId('exact_${taskId}_$dateKey'),
        title: '🔔 Agora: $title',
        body: 'Horário do evento ($category) marcado para hoje $timeDesc!',
        triggerAt: dueDateTime,
        dateKey: dateKey,
      );
    }
  }

  /// Chamado imediatamente quando o usuário marca/cria um novo evento
  Future<void> notifyEventScheduled({
    required String taskId,
    required String title,
    required String time,
    required String dateKey,
    required String category,
    BuildContext? context,
  }) async {
    await requestAndroidNotificationPermission();

    final parts = dateKey.split('-');
    final formattedDate = parts.length == 3
        ? '${parts[2]}/${parts[1]}/${parts[0]}'
        : dateKey;
    final formattedTime = (time.isNotEmpty && time != 'Sem horário')
        ? 'às $time'
        : '(dia todo)';

    // Dispara notificação nativa no Android confirmando o evento marcado
    await showAndroidNotification(
      id: _computeAndroidId('created_${taskId}_$dateKey'),
      title: '📅 Evento marcado: $title',
      body: 'Agendado para $formattedDate $formattedTime • Categoria: $category',
      dateKey: dateKey,
    );

    final due = parseDueDateTime(dateKey, time);
    if (due != null) {
      await _scheduleEventAlarms(
        taskId: taskId,
        title: title,
        time: time,
        dateKey: dateKey,
        category: category,
        dueDateTime: due,
      );
    }

    // Marca como já notificado na criação para evitar duplicata imediata no checkUpcomingEvents
    final notifId = 'notif_${taskId}_$dateKey';
    _androidNotifiedIds.add(notifId);
    await _saveAndroidNotifiedIds();

    await checkUpcomingEvents(
      context: (context != null && context.mounted) ? context : null,
    );
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

  Future<void> _loadPersistedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getStringList(_dismissedKey) ?? [];
      _dismissedNotificationIds.addAll(dismissed);
      final notified = prefs.getStringList(_androidNotifiedKey) ?? [];
      _androidNotifiedIds.addAll(notified);
    } catch (e) {
      debugPrint('Erro ao carregar notificações persistidas: $e');
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

  Future<void> _saveAndroidNotifiedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _androidNotifiedKey,
        _androidNotifiedIds.toList(),
      );
    } catch (e) {
      debugPrint('Erro ao salvar IDs notificados no Android: $e');
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

  /// Carrega todas as tarefas/eventos (locais e do Firestore), agenda alarmes no Android
  /// e verifica os que vencem nas próximas 24h
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
          for (final entry in decoded.entries) {
            final dateKey = entry.key;
            final taskListRaw = entry.value;
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
                    await _scheduleEventAlarms(
                      taskId: taskId,
                      title: title,
                      time: time,
                      dateKey: dateKey,
                      category: category,
                      dueDateTime: due,
                    );

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
          }
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
            await _scheduleEventAlarms(
              taskId: taskId,
              title: title,
              time: time,
              dateKey: dateKey,
              category: category,
              dueDateTime: due,
            );

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

    // Dispara notificação nativa no Android para eventos nas próximas 24h que ainda não foram notificados
    bool androidNotifiedChanged = false;
    for (final n in found) {
      if (!n.isDismissed && !_androidNotifiedIds.contains(n.id)) {
        _androidNotifiedIds.add(n.id);
        androidNotifiedChanged = true;
        await showAndroidNotification(
          id: _computeAndroidId(n.id),
          title: '⏰ Lembrete: ${n.title}',
          body: '${n.dueLabel} • ${n.remainingTimeFormatted} (${n.category})',
          dateKey: n.dateKey,
        );
      }
    }
    if (androidNotifiedChanged) {
      await _saveAndroidNotifiedIds();
    }

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

    await cancelAndroidNotification(_computeAndroidId(notificationId));

    // Atualiza a lista ativa
    final current = activeNotificationsNotifier.value;
    activeNotificationsNotifier.value = current
        .map((n) => n.id == notificationId ? n.copyWith(isDismissed: true) : n)
        .toList();
  }

  /// Remove notificações e alarmes associados a uma tarefa deletada
  Future<void> removeNotificationForTask(String taskId, {String? dateKey}) async {
    final matching = activeNotificationsNotifier.value
        .where((n) => n.taskId == taskId)
        .toList();

    for (final n in matching) {
      await cancelAndroidNotification(_computeAndroidId(n.id));
      await cancelAndroidNotification(_computeAndroidId('created_${n.taskId}_${n.dateKey}'));
      await cancelAndroidNotification(_computeAndroidId('rem24_${n.taskId}_${n.dateKey}'));
      await cancelAndroidNotification(_computeAndroidId('rem1h_${n.taskId}_${n.dateKey}'));
      await cancelAndroidNotification(_computeAndroidId('exact_${n.taskId}_${n.dateKey}'));
    }

    if (dateKey != null) {
      await cancelAndroidNotification(_computeAndroidId('notif_${taskId}_$dateKey'));
      await cancelAndroidNotification(_computeAndroidId('created_${taskId}_$dateKey'));
      await cancelAndroidNotification(_computeAndroidId('rem24_${taskId}_$dateKey'));
      await cancelAndroidNotification(_computeAndroidId('rem1h_${taskId}_$dateKey'));
      await cancelAndroidNotification(_computeAndroidId('exact_${taskId}_$dateKey'));
    }

    _shownNotificationIds.removeWhere((id) => id.contains(taskId));
    _dismissedNotificationIds.removeWhere((id) => id.contains(taskId));
    _androidNotifiedIds.removeWhere((id) => id.contains(taskId));
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
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
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
          ),
        );
      },
    );
  }
}
