import 'package:flutter/material.dart';
import '../widgets/animations.dart';

// Modelo de Dados para as Tarefas
class TaskModel {
  final String id;
  final String title;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  TaskModel({
    String? id,
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
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
  // Controle de Data Dinâmico
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  // Mapa com a Chave no Formato "YYYY-MM-DD"
  final Map<String, List<TaskModel>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);

    // Tarefas iniciais de exemplo
    final todayKey = _formatDateKey(_selectedDate);
    _tasksByDate[todayKey] = [
      TaskModel(
        title: 'Redação: Inteligência Artificial',
        time: '14:00',
        icon: Icons.article_rounded,
        iconColor: const Color(0xFFFFAB8C),
        iconBgColor: const Color(0xFFFFF0EA),
      ),
      TaskModel(
        title: 'Simulado de Matemática',
        time: '09:30',
        icon: Icons.functions_rounded,
        iconColor: const Color(0xFF9EE08F),
        iconBgColor: const Color(0xFFECFCE8),
      ),
    ];
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

  // Deletar Tarefa
  void _deleteTask(String dateKey, String taskId) {
    setState(() {
      _tasksByDate[dateKey]?.removeWhere((t) => t.id == taskId);
      if (_tasksByDate[dateKey]?.isEmpty ?? false) {
        _tasksByDate.remove(dateKey);
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evento removido com sucesso!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                      onTap: () {
                        final title = titleController.text.trim();
                        final time = timeController.text.trim();

                        if (title.isEmpty) return;

                        final dateKey = _formatDateKey(_selectedDate);
                        final selectedIcon = availableIcons[selectedIconIndex];

                        final newTask = TaskModel(
                          title: title,
                          time: time.isNotEmpty ? time : 'Sem horário',
                          icon: selectedIcon.icon,
                          iconColor: selectedIcon.color,
                          iconBgColor: selectedIcon.bgColor,
                        );

                        setState(() {
                          if (_tasksByDate.containsKey(dateKey)) {
                            _tasksByDate[dateKey]!.add(newTask);
                          } else {
                            _tasksByDate[dateKey] = [newTask];
                          }
                        });

                        Navigator.pop(bottomSheetContext);
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
    final selectedKey = _formatDateKey(_selectedDate);
    final currentTasks = _tasksByDate[selectedKey] ?? [];

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

              // CONTAINER PRINCIPAL LILÁS PASTEL ORIGINAL COM ANIMAÇÃO
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mês e Setas Interativas Originais
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                          // Grid dos Dias do Mês com Animação
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

                              final dayNumber = index - startOffset + 1;
                              final dateOfCell = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month,
                                dayNumber,
                              );

                              final isSelected =
                                  dateOfCell.year == _selectedDate.year &&
                                      dateOfCell.month == _selectedDate.month &&
                                      dateOfCell.day == _selectedDate.day;

                              final cellKey = _formatDateKey(dateOfCell);
                              final hasTasks = _tasksByDate.containsKey(cellKey) &&
                                  _tasksByDate[cellKey]!.isNotEmpty;

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                onTap: () => _openAddTaskModal(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
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

                          // Lista com Suporte a Deslizar para Deletar
                          if (currentTasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
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
                                      onTap: () => _openAddTaskModal(context),
                                      child: const Text(
                                        '+ Criar Evento Agora',
                                        style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
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
                              physics: const NeverScrollableScrollPhysics(),
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
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    _deleteTask(selectedKey, task.id);
                                  },
                                  child: _TaskCard(
                                    icon: task.icon,
                                    iconColor: task.iconColor,
                                    iconBgColor: task.iconBgColor,
                                    title: task.title,
                                    time: task.time,
                                    onDelete: () =>
                                        _deleteTask(selectedKey, task.id),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
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