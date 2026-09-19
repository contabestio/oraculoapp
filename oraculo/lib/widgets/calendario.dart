import 'package:flutter/material.dart';

class DatesAndTasksPage extends StatefulWidget {
  const DatesAndTasksPage({super.key});

  @override
  State<DatesAndTasksPage> createState() => _DatesAndTasksPageState();
}

class _DatesAndTasksPageState extends State<DatesAndTasksPage> {
  int selectedDay = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ==========================================================
              // BARRA SUPERIOR (Pílula Coral/Salmão Pastel + Ícone 'X')
              // ==========================================================
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFAB8C), // Cor exata da pílula
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
                    color: const Color(0xFFE5D9FA), // Lilás pastel exato da imagem
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mês e Setas de Navegação
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

                        // Siglas dos Dias da Semana
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

                            return CalendarDay(
                              day: day,
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  selectedDay = day;
                                });
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Linha Divisora Branca Suave
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),

                        const SizedBox(height: 20),

                        // Título Próximas Entregas
                        const Text(
                          'Próximas Entregas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Cards de Tarefas da Lista
                        const _TaskCard(
                          icon: Icons.article_rounded,
                          iconColor: Color(0xFFFFAB8C),
                          iconBgColor: Color(0xFFFFF0EA),
                          title: 'Redação: Inteligência ...',
                          time: '14:00',
                        ),

                        const SizedBox(height: 12),

                        const _TaskCard(
                          icon: Icons.functions_rounded,
                          iconColor: Color(0xFF9EE08F),
                          iconBgColor: Color(0xFFECFCE8),
                          title: 'Simulado de Matemática',
                          time: '09:30',
                        ),

                        const SizedBox(height: 12),

                        const _TaskCard(
                          icon: Icons.menu_book_rounded,
                          iconColor: Color(0xFFFCD068),
                          iconBgColor: Color(0xFFFFF7E3),
                          title: 'Leitura: Dom Casmurro',
                          time: '18:00',
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
// DIA DO CALENDÁRIO
// ============================================================
class CalendarDay extends StatelessWidget {
  final int day;
  final bool selected;
  final VoidCallback? onTap;

  const CalendarDay({
    super.key,
    required this.day,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFAB8C) : Colors.transparent, // Coral Pastel
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