import 'package:flutter/material.dart';
import '../widgets/calendario.dart';
import '../widgets/event.dart';

class DatesAndTasksPage extends StatefulWidget {
  const DatesAndTasksPage({super.key});

  @override
  State<DatesAndTasksPage> createState() =>
      _DatesAndTasksPageState();
}

class _DatesAndTasksPageState
    extends State<DatesAndTasksPage> {
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  final List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final List<String> weekDays = [
    'D',
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
  ];

  // ==========================================================
  // MÊS ANTERIOR
  // ==========================================================

  void previousMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month - 1,
        1,
      );
    });
  }

  // ==========================================================
  // PRÓXIMO MÊS
  // ==========================================================

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
        1,
      );
    });
  }

  // ==========================================================
  // VERIFICA DIA SELECIONADO
  // ==========================================================

  bool isSelected(int day) {
    return selectedDate.year == currentMonth.year &&
        selectedDate.month == currentMonth.month &&
        selectedDate.day == day;
  }

  // ==========================================================
  // GERA CALENDÁRIO
  // ==========================================================

  List<Widget> buildCalendar() {
    final firstDay = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    final lastDay = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    final startingOffset = firstDay.weekday % 7;
    final totalDays = lastDay.day;

    final List<Widget> cells = [];

    // Espaços antes do primeiro dia
    for (int i = 0; i < startingOffset; i++) {
      cells.add(
        const SizedBox(
          width: 40,
          height: 40,
        ),
      );
    }

    // Dias do mês
    for (int day = 1; day <= totalDays; day++) {
      cells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = DateTime(
                currentMonth.year,
                currentMonth.month,
                day,
              );
            });
          },
          child: CalendarDay(
            day: day,
            selected: isSelected(day),
          ),
        ),
      );
    }

    // Completa a última semana
    while (cells.length % 7 != 0) {
      cells.add(
        const SizedBox(
          width: 40,
          height: 40,
        ),
      );
    }

    return cells;
  }

  // ==========================================================
  // MONTA AS LINHAS
  // ==========================================================

  List<Widget> buildRows() {
    final cells = buildCalendar();

    final List<Widget> rows = [];

    for (int i = 0; i < cells.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: cells.sublist(i, i + 7),
        ),
      );
    }

    return rows;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Color(0xFFFFA77F),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFA77F),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'Datas e Pendências',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================
      // CORPO
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2ED),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // MÊS
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${months[currentMonth.month - 1]}, '
                    '${currentMonth.year}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: previousMonth,
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                        ),
                      ),

                      IconButton(
                        onPressed: nextMonth,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DIAS DA SEMANA
              // ==================================================

              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: weekDays.map((day) {
                    return SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // DIAS
              // ==================================================

              Column(
                children: buildRows()
                    .map(
                      (row) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: row,
                      ),
                    )
                    .toList(),
              ),

              const Divider(
                height: 30,
              ),

              // ==================================================
              // ENTREGAS
              // ==================================================

              const Text(
                'Próximas Entregas',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const EventItem(
                icon: Icons.description_rounded,
                time: '14:00',
                title:
                    'Redação: Inteligência Artificial',
                color: Color(0xFFFFA77F),
              ),

              const SizedBox(height: 12),

              const EventItem(
                icon: Icons.functions_rounded,
                time: '09:30',
                title: 'Simulado de Matemática',
                color: Colors.purple,
              ),

              const SizedBox(height: 12),

              const EventItem(
                icon: Icons.auto_stories_rounded,
                time: '18:00',
                title: 'Leitura: Dom Casmurro',
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
