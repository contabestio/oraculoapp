import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animations.dart';

// ==========================================================
// MODELO DE DADOS PARA TAREFAS / EVENTOS (FIRESTORE & LOCAL)
// ==========================================================

class TaskModel {
  final String id;
  final String title;
  final String time;
  final String dateKey;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String category;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.time,
    required this.dateKey,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'dateKey': dateKey,
      'iconCodePoint': icon.codePoint,
      'iconColor': iconColor.toARGB32(),
      'iconBgColor': iconBgColor.toARGB32(),
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static IconData resolveIcon(String category, int? codePoint) {
    if (codePoint != null) {
      if (codePoint == Icons.article_rounded.codePoint) {
        return Icons.article_rounded;
      }
      if (codePoint == Icons.menu_book_rounded.codePoint) {
        return Icons.menu_book_rounded;
      }
      if (codePoint == Icons.functions_rounded.codePoint) {
        return Icons.functions_rounded;
      }
      if (codePoint == Icons.groups_rounded.codePoint) {
        return Icons.groups_rounded;
      }
      if (codePoint == Icons.event_note_rounded.codePoint) {
        return Icons.event_note_rounded;
      }
    }
    switch (category.trim().toLowerCase()) {
      case 'redação':
      case 'redacao':
        return Icons.article_rounded;
      case 'leitura':
        return Icons.menu_book_rounded;
      case 'exatas':
        return Icons.functions_rounded;
      case 'reunião':
      case 'reuniao':
        return Icons.groups_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final int? iconCode = (json['iconCodePoint'] as num?)?.toInt();
    final String category = json['category'] as String? ?? 'Geral';
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      time: json['time'] as String? ?? '',
      dateKey: json['dateKey'] as String? ?? '',
      icon: resolveIcon(category, iconCode),
      iconColor: Color((json['iconColor'] as num?)?.toInt() ?? 0xFFFFAB8C),
      iconBgColor: Color((json['iconBgColor'] as num?)?.toInt() ?? 0xFFFFF0EA),
      category: category,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data() ?? {};
      final createTimestamp = data['createdAt'] as Timestamp?;
      final int? iconCode = (data['iconCodePoint'] as num?)?.toInt();
      final int iconColorVal =
          (data['iconColor'] as num?)?.toInt() ?? 0xFFFFAB8C;
      final int iconBgColorVal =
          (data['iconBgColor'] as num?)?.toInt() ?? 0xFFFFF0EA;
      final String category = (data['category'] as String?)?.trim() ?? 'Geral';

      return TaskModel(
        id: doc.id,
        title: (data['title'] as String?)?.trim() ?? '',
        time: (data['time'] as String?)?.trim() ?? '',
        dateKey: (data['dateKey'] as String?)?.trim() ?? '',
        icon: resolveIcon(category, iconCode),
        iconColor: Color(iconColorVal),
        iconBgColor: Color(iconBgColorVal),
        category: category,
        createdAt: createTimestamp?.toDate() ?? DateTime.now(),
      );
    } catch (_) {
      return TaskModel(
        id: doc.id,
        title: 'Evento',
        time: '',
        dateKey: '',
        icon: Icons.event_note_rounded,
        iconColor: const Color(0xFFFFAB8C),
        iconBgColor: const Color(0xFFFFF0EA),
        category: 'Geral',
        createdAt: DateTime.now(),
      );
    }
  }
}

// Opções de ícones originais para o usuário selecionar
class IconOption {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const IconOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

const List<IconOption> availableIcons = [
  IconOption(
    icon: Icons.article_rounded,
    label: 'Redação',
    color: Color(0xFFFFAB8C),
    bgColor: Color(0xFFFFF0EA),
  ),
  IconOption(
    icon: Icons.menu_book_rounded,
    label: 'Leitura',
    color: Color(0xFFFCD068),
    bgColor: Color(0xFFFFF7E3),
  ),
  IconOption(
    icon: Icons.functions_rounded,
    label: 'Exatas',
    color: Color(0xFF9EE08F),
    bgColor: Color(0xFFECFCE8),
  ),
  IconOption(
    icon: Icons.groups_rounded,
    label: 'Reunião',
    color: Color(0xFF7CA1FF),
    bgColor: Color(0xFFEFF4FF),
  ),
  IconOption(
    icon: Icons.event_note_rounded,
    label: 'Geral',
    color: Color(0xFFD393FF),
    bgColor: Color(0xFFF8EFFE),
  ),
];

class DatesAndTasksPage extends StatefulWidget {
  const DatesAndTasksPage({super.key});

  @override
  State<DatesAndTasksPage> createState() => _DatesAndTasksPageState();
}

class _DatesAndTasksPageState extends State<DatesAndTasksPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controle de Data Dinâmico
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  // Lista local persistida via SharedPreferences
  final Map<String, List<TaskModel>> _localTasksByDate = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadLocalTasks().then((_) {
      _syncLocalTasksToFirestore();
    });
  }

  // ==========================================================
  // PERSISTÊNCIA LOCAL (SHARED PREFERENCES)
  // ==========================================================

  Future<void> _loadLocalTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('oraculo_local_tasks_data');
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        if (!mounted) return;
        setState(() {
          _localTasksByDate.clear();
          decoded.forEach((key, listRaw) {
            if (listRaw is List) {
              _localTasksByDate[key] = listRaw
                  .map((item) =>
                      TaskModel.fromJson(Map<String, dynamic>.from(item)))
                  .toList();
            }
          });
        });
        return;
      }
    } catch (e) {
      debugPrint('Erro ao carregar tarefas locais: $e');
    }
  }

  Future<void> _saveLocalTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toEncode = {};
      _localTasksByDate.forEach((key, list) {
        toEncode[key] = list.map((t) => t.toJson()).toList();
      });
      await prefs.setString('oraculo_local_tasks_data', jsonEncode(toEncode));
    } catch (e) {
      debugPrint('Erro ao salvar tarefas locais: $e');
    }
  }

  /// Quando o usuário estiver autenticado, faz o upload automático de quaisquer eventos locais criados offline
  Future<void> _syncLocalTasksToFirestore() async {
    final collection = _getUserTasksCollection();
    if (collection == null || _localTasksByDate.isEmpty) return;

    try {
      bool anySynced = false;
      final localKeys = List<String>.from(_localTasksByDate.keys);
      for (final key in localKeys) {
        final tasks = _localTasksByDate[key] ?? [];
        for (final task in tasks) {
          await collection.add({
            'title': task.title,
            'time': task.time,
            'dateKey': task.dateKey,
            'iconCodePoint': task.icon.codePoint,
            'iconColor': task.iconColor.toARGB32(),
            'iconBgColor': task.iconBgColor.toARGB32(),
            'category': task.category,
            'createdAt': Timestamp.fromDate(task.createdAt),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          anySynced = true;
        }
      }

      if (anySynced && mounted) {
        setState(() {
          _localTasksByDate.clear();
        });
        await _saveLocalTasks();
        _showMessage('Eventos sincronizados com sua conta na nuvem!');
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar eventos locais com o Firestore: $e');
    }
  }

  /// Retorna a subcoleção de tarefas/eventos do usuário no Firestore:
  /// users/{uid}/tasks
  CollectionReference<Map<String, dynamic>>? _getUserTasksCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  String _formatDateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  int _daysInMonth(DateTime month) {
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  int _firstWeekdayOfMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    return firstDay.weekday % 7;
  }

  void _changeMonth(int increment) {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + increment);
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFFF6B6B) : const Color(0xFF594A6D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Criar Tarefa no Firestore ou Localmente
  Future<void> _addTask({
    required String title,
    required String time,
    required String dateKey,
    required IconOption selectedOption,
  }) async {
    final collection = _getUserTasksCollection();

    if (collection != null) {
      try {
        await collection.add({
          'title': title,
          'time': time,
          'dateKey': dateKey,
          'iconCodePoint': selectedOption.icon.codePoint,
          'iconColor': selectedOption.color.toARGB32(),
          'iconBgColor': selectedOption.bgColor.toARGB32(),
          'category': selectedOption.label,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _showMessage('Evento salvo com sucesso na nuvem!');
        return;
      } on FirebaseException catch (e) {
        debugPrint('FirebaseException addTask: [${e.code}] ${e.message}');
        String errorMessage = 'Erro ao salvar evento na nuvem.';
        if (e.code == 'permission-denied') {
          errorMessage = 'Permissão negada no Firestore.';
        } else if (e.code == 'unavailable') {
          errorMessage = 'Sem conexão. Salvando localmente no aparelho.';
        }
        _showMessage(errorMessage, isError: true);
      } catch (e) {
        debugPrint('Erro Firestore inesperado: $e');
        _showMessage('Erro ao salvar no banco. Salvando localmente.', isError: true);
      }
    }

    // Se estiver sem conexão ou sem autenticação, salva localmente com persistência
    final newTask = TaskModel(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      time: time,
      dateKey: dateKey,
      icon: selectedOption.icon,
      iconColor: selectedOption.color,
      iconBgColor: selectedOption.bgColor,
      category: selectedOption.label,
      createdAt: DateTime.now(),
    );

    setState(() {
      if (!_localTasksByDate.containsKey(dateKey)) {
        _localTasksByDate[dateKey] = [];
      }
      _localTasksByDate[dateKey]!.add(newTask);
    });
    await _saveLocalTasks();

    _showMessage(
      collection == null
          ? 'Evento salvo no aparelho! Conecte sua conta para salvar na nuvem.'
          : 'Evento salvo localmente no aparelho.',
    );
  }

  // Deletar Tarefa
  Future<void> _deleteTask(String taskId, String dateKey) async {
    final collection = _getUserTasksCollection();

    // Se for tarefa local persistida
    if (taskId.startsWith('local_') ||
        _localTasksByDate[dateKey]?.any((t) => t.id == taskId) == true) {
      setState(() {
        _localTasksByDate[dateKey]?.removeWhere((t) => t.id == taskId);
      });
      await _saveLocalTasks();
      _showMessage('Evento removido com sucesso!');
      return;
    }

    if (collection != null) {
      try {
        await collection.doc(taskId).delete();
        _showMessage('Evento removido da nuvem!');
        return;
      } on FirebaseException catch (e) {
        debugPrint('Erro ao remover do Firestore: [${e.code}] ${e.message}');
        String errorMessage = 'Erro ao remover do banco.';
        if (e.code == 'permission-denied') {
          errorMessage = 'Permissão negada ao remover evento.';
        }
        _showMessage(errorMessage, isError: true);
        return;
      } catch (e) {
        debugPrint('Erro inesperado delete: $e');
      }
    }

    setState(() {
      _localTasksByDate[dateKey]?.removeWhere((t) => t.id == taskId);
    });
    await _saveLocalTasks();
    _showMessage('Evento removido com sucesso!');
  }

  // Modal para Criar Evento com Escolha de Ícone Original
  void _openAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    int selectedIconIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5D9FA),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Novo Evento (${_selectedDate.day}/${_selectedDate.month})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                        BouncingPressable(
                          onTap: () => Navigator.pop(bottomSheetContext),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFFFAB8C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo de Título
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        hintText: 'Título do Evento (ex: Estudar Física)',
                        filled: true,
                        fillColor: const Color(0xFFF7F7F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Campo de Horário
                    TextField(
                      controller: timeController,
                      style: const TextStyle(color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        hintText: 'Horário (ex: 15:30)',
                        filled: true,
                        fillColor: const Color(0xFFF7F7F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Selecione uma Categoria:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Lista de Ícones Originais com Animação
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: availableIcons.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final option = availableIcons[index];
                          final isSelected = selectedIconIndex == index;

                          return BouncingPressable(
                            onTap: () {
                              setModalState(() {
                                selectedIconIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? option.color
                                    : option.bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    option.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : option.color,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : option.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botão Salvar Evento
                    BouncingPressable(
                      onTap: () async {
                        final title = titleController.text.trim();
                        final time = timeController.text.trim();

                        if (title.isEmpty) {
                          _showMessage('Digite o título do evento.', isError: true);
                          return;
                        }

                        final dateKey = _formatDateKey(_selectedDate);
                        final selectedIcon = availableIcons[selectedIconIndex];

                        Navigator.pop(bottomSheetContext);

                        await _addTask(
                          title: title,
                          time: time.isNotEmpty ? time : 'Sem horário',
                          dateKey: dateKey,
                          selectedOption: selectedIcon,
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFAB8C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Salvar Evento',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final collection = _getUserTasksCollection();
    final selectedKey = _formatDateKey(_selectedDate);

    final daysInCurrentMonth = _daysInMonth(_focusedMonth);
    final startOffset = _firstWeekdayOfMonth(_focusedMonth);
    final totalGridItems = daysInCurrentMonth + startOffset;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // BARRA SUPERIOR ORIGINAL COM ANIMAÇÃO
              FadeSlideTransition(
                delay: const Duration(milliseconds: 50),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFAB8C),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Datas e Pendências',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    BouncingPressable(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFFFAB8C),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CONTAINER PRINCIPAL LILÁS PASTEL - NUNCA TRAVA EM TELA DE CARREGAMENTO
              Expanded(
                child: FadeSlideTransition(
                  delay: const Duration(milliseconds: 150),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5D9FA),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: collection?.snapshots(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final List<TaskModel> firestoreTasks = docs
                            .map((doc) => TaskModel.fromFirestore(doc))
                            .toList();

                        // Agrupa tarefas (do Firestore + locais) por data
                        final Map<String, List<TaskModel>> tasksByDate = {};

                        // Adiciona tarefas locais se houver
                        _localTasksByDate.forEach((key, list) {
                          tasksByDate[key] = List.from(list);
                        });

                        // Adiciona tarefas do Firestore
                        for (final t in firestoreTasks) {
                          if (!tasksByDate.containsKey(t.dateKey)) {
                            tasksByDate[t.dateKey] = [];
                          }
                          tasksByDate[t.dateKey]!.add(t);
                        }

                        final currentTasks = tasksByDate[selectedKey] ?? [];

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status de Conexão Nuvem / Local
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      collection != null
                                          ? (snapshot.hasError
                                              ? Icons.cloud_off_rounded
                                              : Icons.cloud_done_rounded)
                                          : Icons.cloud_queue_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        collection != null
                                            ? (snapshot.hasError
                                                ? 'Erro no Firestore: ${snapshot.error}'
                                                : 'Nuvem sincronizada (${_auth.currentUser?.email ?? 'Usuário'})')
                                            : 'Modo Local (Offline) • Eventos salvos no aparelho',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Mês e Setas Interativas Originais
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_getMonthName(_focusedMonth.month)}, ${_focusedMonth.year}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      BouncingPressable(
                                        onTap: () => _changeMonth(-1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.chevron_left,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      BouncingPressable(
                                        onTap: () => _changeMonth(1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Siglas da Semana Originais
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const [
                                  _WeekdayText('D'),
                                  _WeekdayText('S'),
                                  _WeekdayText('T'),
                                  _WeekdayText('Q'),
                                  _WeekdayText('Q'),
                                  _WeekdayText('S'),
                                  _WeekdayText('S'),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Grid dos Dias do Mês com Indicador
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: totalGridItems,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 6,
                                ),
                                itemBuilder: (context, index) {
                                  if (index < startOffset) {
                                    return const SizedBox.shrink();
                                  }

                                  final dayNumber =
                                      index - startOffset + 1;
                                  final dateOfCell = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month,
                                    dayNumber,
                                  );

                                  final isSelected =
                                      dateOfCell.year == _selectedDate.year &&
                                          dateOfCell.month ==
                                              _selectedDate.month &&
                                          dateOfCell.day ==
                                              _selectedDate.day;

                                  final cellKey =
                                      _formatDateKey(dateOfCell);
                                  final hasTasks = tasksByDate
                                          .containsKey(cellKey) &&
                                      tasksByDate[cellKey]!.isNotEmpty;

                                  return CalendarDay(
                                    day: dayNumber,
                                    selected: isSelected,
                                    hasTask: hasTasks,
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = dateOfCell;
                                      });
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),

                              const SizedBox(height: 20),

                              // Cabeçalho de Entregas + Botão Adicionar Evento Original
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Entregas (${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  BouncingPressable(
                                    onTap: () =>
                                        _openAddTaskModal(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.add_rounded,
                                            color: Color(0xFFFFAB8C),
                                            size: 18,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Evento',
                                            style: TextStyle(
                                              color: Color(0xFFFFAB8C),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Lista de Tarefas (Zero dados padrão ou Carregando)
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  !snapshot.hasData &&
                                  _localTasksByDate.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Carregando eventos...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else if (currentTasks.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Nenhum evento neste dia',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        BouncingPressable(
                                          onTap: () =>
                                              _openAddTaskModal(context),
                                          child: const Text(
                                            '+ Criar Evento Agora',
                                            style: TextStyle(
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: currentTasks.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final task = currentTasks[index];

                                    return Dismissible(
                                      key: Key(task.id),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B6B),
                                          borderRadius:
                                              BorderRadius.circular(28),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      onDismissed: (direction) {
                                        _deleteTask(task.id, selectedKey);
                                      },
                                      child: _TaskCard(
                                        icon: task.icon,
                                        iconColor: task.iconColor,
                                        iconBgColor: task.iconBgColor,
                                        title: task.title,
                                        time: task.time,
                                        onDelete: () =>
                                            _deleteTask(task.id, selectedKey),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// DIA DO CALENDÁRIO COM CORES ORIGINAIS E ANIMAÇÃO DE COMPRESSÃO
class CalendarDay extends StatelessWidget {
  final int day;
  final bool selected;
  final bool hasTask;
  final VoidCallback? onTap;

  const CalendarDay({
    super.key,
    required this.day,
    required this.selected,
    this.hasTask = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (selected) {
        return const Color(0xFFFFAB8C);
      }
      if (hasTask) {
        return const Color(0xFFFFF0EA);
      }
      return Colors.transparent;
    }

    Color getTextColor() {
      if (selected) {
        return Colors.white;
      }
      if (hasTask) {
        return const Color(0xFFE87A53);
      }
      return const Color(0xFF333333);
    }

    return BouncingPressable(
      onTap: onTap,
      scaleFactor: 0.90,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: getBackgroundColor(),
                shape: BoxShape.circle,
                border: hasTask && !selected
                    ? Border.all(color: const Color(0xFFFFAB8C), width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: getTextColor(),
                  fontWeight: (selected || hasTask)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
            if (hasTask)
              Positioned(
                bottom: 3,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : const Color(0xFFFFAB8C),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// SIGLA DO DIA DA SEMANA ORIGINAL
class _WeekdayText extends StatelessWidget {
  final String text;
  const _WeekdayText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// CARD DE TAREFA COM CORES E SÍMBOLOS ORIGINAIS + ANIMAÇÃO
class _TaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String time;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.time,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2B2B2B),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF8E8E8E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Botão Excluir Lixeira Original com Animação
          BouncingPressable(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFF8888),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}