import 'package:flutter/material.dart';
import '../models/enem_question_model.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

/// Card de Questão estilizado no modelo oficial dos Cadernos de Prova do ENEM.
///
/// Reproduz fielmente a identidade visual impressa:
/// - Cabeçalho: "QUESTÃO XX" com traço horizontal contínuo à direita
/// - Texto de apoio e comando com tipografia nítida e justificada
/// - Alternativas identificadas por círculos pretos com letras em branco (A, B, C, D, E)
/// - Traço duplo de encerramento no rodapé da questão
/// - Resolução comentada e gabarito oficial com feedback interativo
class EnemQuestionCard extends StatelessWidget {
  final EnemQuestionModel question;
  final int? selectedOption;
  final bool isConfirmed;
  final ValueChanged<int>? onSelectOption;
  final VoidCallback? onConfirmAnswer;
  final bool showExplanation;
  final VoidCallback? onToggleExplanation;

  const EnemQuestionCard({
    super.key,
    required this.question,
    this.selectedOption,
    this.isConfirmed = false,
    this.onSelectOption,
    this.onConfirmAnswer,
    this.showExplanation = false,
    this.onToggleExplanation,
  });

  static const List<String> _letters = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    final hasAnswered = isConfirmed && selectedOption != null;
    final isCorrect = hasAnswered && selectedOption == question.correctOptionIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAnswered
              ? (isCorrect ? const Color(0xFF2E7D32).withValues(alpha: 0.5) : const Color(0xFFC62828).withValues(alpha: 0.4))
              : const Color(0xFFE2E2E6),
          width: hasAnswered ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================================
            // CABEÇALHO CLÁSSICO DO ENEM: "QUESTÃO XX ──────────"
            // ========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'QUESTÃO ${question.number}',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 2.8,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (question.yearSource != null && question.yearSource!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD6D6DC)),
                    ),
                    child: Text(
                      question.yearSource!,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // ========================================================
            // TEXTO DE APOIO / CONTEXTO (se houver)
            // ========================================================
            if (question.contextText != null && question.contextText!.trim().isNotEmpty) ...[
              Text(
                question.contextText!,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14.2,
                  color: Color(0xFF1A1A1A),
                  height: 1.48,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
            ],

            // ========================================================
            // COMANDO DA QUESTÃO
            // ========================================================
            Text(
              question.questionText,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14.5,
                fontWeight: question.contextText != null ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF111111),
                height: 1.45,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // ========================================================
            // ALTERNATIVAS A, B, C, D, E (Círculo preto com letra branca)
            // ========================================================
            ...List.generate(question.options.length, (index) {
              final isChosen = selectedOption == index;
              final isCorrectOption = index == question.correctOptionIndex;
              final letter = index < _letters.length ? _letters[index] : '${index + 1}';

              // Cores do círculo e do fundo conforme estado
              Color circleBg = Colors.black;
              Color circleText = Colors.white;
              Color itemBg = Colors.transparent;
              Border? itemBorder;

              if (hasAnswered) {
                if (isCorrectOption) {
                  circleBg = const Color(0xFF2E7D32); // Verde oficial de acerto
                  circleText = Colors.white;
                  itemBg = const Color(0xFFE8F5E9);
                  itemBorder = Border.all(color: const Color(0xFF81C784), width: 1.2);
                } else if (isChosen && !isCorrect) {
                  circleBg = const Color(0xFFC62828); // Vermelho de erro
                  circleText = Colors.white;
                  itemBg = const Color(0xFFFFEBEE);
                  itemBorder = Border.all(color: const Color(0xFFE57373), width: 1.2);
                }
              } else if (isChosen) {
                circleBg = AppTheme.orange; // Seleção pendente
                circleText = Colors.white;
                itemBg = AppTheme.orangeBg.withValues(alpha: 0.6);
                itemBorder = Border.all(color: AppTheme.orange.withValues(alpha: 0.6), width: 1.2);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BouncingPressable(
                  scaleFactor: isConfirmed ? 1.0 : 0.985,
                  onTap: isConfirmed
                      ? null
                      : () {
                          if (onSelectOption != null) {
                            onSelectOption!(index);
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(10),
                      border: itemBorder,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Círculo com letra (Estilo visual idêntico à prova do ENEM)
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 1, right: 10),
                          decoration: BoxDecoration(
                            color: circleBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: circleText,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Arial',
                              height: 1.0,
                            ),
                          ),
                        ),
                        // Texto da alternativa
                        Expanded(
                          child: Text(
                            question.options[index],
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14.0,
                              color: const Color(0xFF111111),
                              height: 1.38,
                              fontWeight: isChosen ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Ícone indicativo após correção
                        if (hasAnswered && isCorrectOption) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                        ] else if (hasAnswered && isChosen && !isCorrect) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.cancel_rounded, color: Color(0xFFC62828), size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // ========================================================
            // TRAÇO DUPLO DE ENCERRAMENTO (Rodapé idêntico à imagem)
            // ========================================================
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(height: 1.4, color: Colors.black),
                      const SizedBox(height: 2.0),
                      Container(height: 1.4, color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ========================================================
            // AÇÕES E FEEDBACK (Confirmar / Ver Resolução Comentada)
            // ========================================================
            if (!isConfirmed && selectedOption != null) ...[
              ElevatedButton.icon(
                onPressed: onConfirmAnswer,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Confirmar Resposta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
              ),
            ] else if (isConfirmed) ...[
              // Banner de Resultado do Aluno
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect ? const Color(0xFFA5D6A7) : const Color(0xFFEF9A9A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                      color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isCorrect
                            ? 'Parabéns! Você acertou a questão.'
                            : 'Resposta incorreta. Gabarito: Letra ${question.correctLetter}.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: isCorrect ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onToggleExplanation,
                      icon: Icon(
                        showExplanation ? Icons.keyboard_arrow_up : Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: AppTheme.orangeDark,
                      ),
                      label: Text(
                        showExplanation ? 'Ocultar' : 'Resolução',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.orangeDark,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),

              // Bloco de Resolução Comentada Expandido
              if (showExplanation) ...[
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E2EA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Gabarito Oficial: Letra ${question.correctLetter}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Resolução Comentada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.darkTextHeading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13.0,
                          color: Color(0xFF333333),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
