import 'package:flutter/material.dart';

// Modelo de Dados para as Tarefas
class TaskModel {
  final String title;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const TaskModel({
    required this.title,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class DatesAndTasksPage extends StatefulWidget {
  const DatesAndTasksPage({super.key});

  @override
  State<DatesAndTasksPage> createState() => _DatesAndTasksPageState();
}

class _DatesAndTasksPageState extends State<DatesAndTasksPage> {
  int selectedDay = 10;

  // Mapa com o Dia como chave e Lista de Tarefas como valor
  final Map<int, List<TaskModel>> tasksByDay = {
    10: [
      const TaskModel(
        title: 'Redação: Inteligência Artificial',
        time: '14:00',
        icon: Icons.article_rounded,
        iconColor: Color(0xFFFFAB8C),
        iconBgColor: Color(0xFFFFF0EA),
      ),
      const TaskModel(
        title: 'Simulado de Matemática',
        time: '09:30',
        icon: Icons.functions_rounded,
        iconColor: Color(0xFF9EE08F),
        iconBgColor: Color(0xFFECFCE8),
      ),
    ],
    12: [
      const TaskModel(
        title: 'Leitura: Dom Casmurro',
        time: '18:00',
        icon: Icons.menu_book_rounded,
        iconColor: Color(0xFFFCD068),
        iconBgColor: Color(0xFFFFF7E3),
      ),
    ],
    15: [
      const TaskModel(
        title: 'Reunião de Grupo',
        time: '16:30',
        icon: Icons.groups_rounded,
        iconColor: Color(0xFF7CA1FF),
        iconBgColor: Color(0xFFEFF4FF),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Busca tarefas do dia selecionado
    final currentTasks = tasksByDay[selectedDay] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ==========================================================
              // BARRA SUPERIOR
              // ==========================================================
              Row(
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFFFAB8C),
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==========================================================
              // CONTAINER PRINCIPAL LILÁS PASTEL
              // ==========================================================
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5D9FA),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mês e Setas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Junho, 2026',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.chevron_left, color: Colors.white, size: 26),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right, color: Colors.white, size: 26),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Siglas da Semana
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

                        // Grid dos Dias do Mês
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 21,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 6,
                          ),
                          itemBuilder: (context, index) {
                            final day = index + 1;
                            final isSelected = day == selectedDay;
                            final hasTasks = tasksByDay.containsKey(day);

                            return CalendarDay(
                              day: day,
                              selected: isSelected,
                              hasTask: hasTasks, // Passa a informação se há tarefa
                              onTap: () {
                                setState(() {
                                  selectedDay = day;
                                });
                              }, hasEvent: false,
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Linha Divisora
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),

                        const SizedBox(height: 20),

                        // Título Dinâmico de Entregas
                        Text(
                          'Próximas Entregas ($selectedDay/06)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Lista Dinâmica de Tarefas do Dia Selecionado
                        if (currentTasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'Nenhuma entrega para este dia 🎉',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentTasks.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = currentTasks[index];
                              return _TaskCard(
                                icon: task.icon,
                                iconColor: task.iconColor,
                                iconBgColor: task.iconBgColor,
                                title: task.title,
                                time: task.time,
                              );
                            },
                          ),
                      ],
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

// ============================================================
// DIA DO CALENDÁRIO COM PONTO INDICADOR
// ============================================================
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
    this.onTap, required bool hasEvent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFAB8C) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF333333),
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
            // Ponto indicador de pendência abaixo do número
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

// ============================================================
// SIGLA DO DIA DA SEMANA
// ============================================================
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

// ============================================================
// CARD DE TAREFA
// ============================================================
class _TaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String time;

  const _TaskCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFCCCCCC),
            size: 22,
          ),
        ],
      ),
    );
  }
}