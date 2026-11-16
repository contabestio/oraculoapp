import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../theme/app_theme.dart';
import 'animations.dart';
import 'enem_question_card.dart';

/// Aba completa de Simulados e Questões Modelo ENEM dentro dos Livros.
///
/// Permite aos estudantes:
/// 1. Resolver todas as questões no estilo gráfico autêntico do ENEM
/// 2. Navegar rapidamente pelas questões através dos botões de atalho
/// 3. Alternar entre visualização de "Caderno Completo" ou "Modo Foco (Questão a Questão)"
/// 4. Conferir gabarito oficial com resolução comentada e taxa de acertos em tempo real
class BookSimuladoTab extends StatefulWidget {
  final BookModel book;

  const BookSimuladoTab({
    super.key,
    required this.book,
  });

  @override
  State<BookSimuladoTab> createState() => _BookSimuladoTabState();
}

class _BookSimuladoTabState extends State<BookSimuladoTab> {
  // Mapa de respostas: índice da questão -> alternativa escolhida (0 a 4)
  final Map<int, int> _userAnswers = {};

  // Conjunto de questões com resposta já confirmada/conferida
  final Set<int> _confirmedQuestions = {};

  // Conjunto de questões com resolução comentada aberta
  final Set<int> _expandedExplanations = {};

  // Modo de exibição: true = foco questão por questão, false = caderno contínuo
  bool _isFocusMode = false;
  int _currentFocusIndex = 0;

  // Modo de correção instantânea (corrige ao tocar na alternativa)
  bool _instantCorrection = true;

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  List<EnemQuestionModel> get _questions => widget.book.questions;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _questions.length; i++) {
      _questionKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToQuestion(int index) {
    if (_isFocusMode) {
      setState(() {
        _currentFocusIndex = index;
      });
      return;
    }

    final key = _questionKeys[index];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        alignment: 0.1,
      );
    }
  }

  void _selectOption(int questionIndex, int optionIndex) {
    setState(() {
      _userAnswers[questionIndex] = optionIndex;
      if (_instantCorrection) {
        _confirmedQuestions.add(questionIndex);
        _expandedExplanations.add(questionIndex);
      }
    });

    _checkCompletion();
  }

  void _confirmAnswer(int questionIndex) {
    setState(() {
      _confirmedQuestions.add(questionIndex);
      _expandedExplanations.add(questionIndex);
    });

    _checkCompletion();
  }

  void _toggleExplanation(int questionIndex) {
    setState(() {
      if (_expandedExplanations.contains(questionIndex)) {
        _expandedExplanations.remove(questionIndex);
      } else {
        _expandedExplanations.add(questionIndex);
      }
    });
  }

  void _resetSimulado() {
    setState(() {
      _userAnswers.clear();
      _confirmedQuestions.clear();
      _expandedExplanations.clear();
      _currentFocusIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Simulado reiniciado! Boa prática.'),
          ],
        ),
        backgroundColor: AppTheme.orangeDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _checkCompletion() {
    if (_confirmedQuestions.length == _questions.length && _questions.isNotEmpty) {
      // Pequeno atraso para o usuário ver o feedback antes da celebração
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _showResultSummary();
      });
    }
  }

  void _showResultSummary() {
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctOptionIndex) {
        correctCount++;
      }
    }
    final percentage = ((correctCount / _questions.length) * 100).round();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              percentage >= 70 ? Icons.military_tech_rounded : Icons.school_rounded,
              color: percentage >= 70 ? AppTheme.orange : const Color(0xFF1976D2),
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Simulado Finalizado!',
              style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: percentage >= 70 ? const Color(0xFFE8F5E9) : AppTheme.orangeBg,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: percentage >= 70 ? const Color(0xFF2E7D32) : AppTheme.orangeDark,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Você acertou $correctCount de ${_questions.length} questões!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              percentage >= 70
                  ? 'Excelente desempenho! Você demonstrou forte domínio dos conceitos cobrados no ENEM.'
                  : 'Bom treino! Revise os gabaritos e resoluções comentadas para sanar as dúvidas.',
              style: const TextStyle(fontSize: 13, color: AppTheme.mutedText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetSimulado();
            },
            child: const Text('Refazer Simulado'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Revisar Questões'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz_outlined, size: 48, color: AppTheme.mutedText),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhuma questão cadastrada para este material.',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Em breve adicionaremos um banco completo de questões no modelo oficial do ENEM.',
                style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Métricas de progresso
    final totalQuestions = _questions.length;
    final answeredCount = _confirmedQuestions.length;
    int correctCount = 0;
    for (final index in _confirmedQuestions) {
      if (_userAnswers[index] == _questions[index].correctOptionIndex) {
        correctCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ========================================================
        // PAINEL DE CONTROLE DO SIMULADO (Progresso e Configurações)
        // ========================================================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8E8EE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha Superior: Título e Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Simulado Oficial Modelo ENEM',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '$totalQuestions questões no padrão de prova',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botão de Reiniciar
                  if (answeredCount > 0)
                    IconButton(
                      tooltip: 'Reiniciar Simulado',
                      icon: const Icon(Icons.refresh_rounded, size: 20, color: AppTheme.mutedText),
                      onPressed: _resetSimulado,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de Progresso e Placar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Respondidas: $answeredCount de $totalQuestions',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.darkText),
                  ),
                  if (answeredCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: correctCount > 0 ? const Color(0xFFE8F5E9) : AppTheme.orangeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Acertos: $correctCount ($answeredCount)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: correctCount > 0 ? const Color(0xFF2E7D32) : AppTheme.orangeDark,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalQuestions > 0 ? (answeredCount / totalQuestions) : 0,
                  backgroundColor: const Color(0xFFE4E4EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.orange),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 14),

              // Régua de Botões de Atalho para cada Questão (1 a 10)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(totalQuestions, (index) {
                    final isConfirmed = _confirmedQuestions.contains(index);
                    final isSelected = _isFocusMode ? _currentFocusIndex == index : false;
                    final isAnswerCorrect = isConfirmed &&
                        _userAnswers[index] == _questions[index].correctOptionIndex;

                    Color btnBg = const Color(0xFFECECEF);
                    Color btnText = const Color(0xFF444444);
                    Border? btnBorder;

                    if (isConfirmed) {
                      if (isAnswerCorrect) {
                        btnBg = const Color(0xFF2E7D32);
                        btnText = Colors.white;
                      } else {
                        btnBg = const Color(0xFFC62828);
                        btnText = Colors.white;
                      }
                    } else if (_userAnswers.containsKey(index)) {
                      btnBg = AppTheme.orangeBg;
                      btnText = AppTheme.orangeDark;
                      btnBorder = Border.all(color: AppTheme.orange, width: 1.2);
                    }

                    if (isSelected) {
                      btnBorder = Border.all(color: Colors.black, width: 2.0);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: BouncingPressable(
                        onTap: () => _scrollToQuestion(index),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: btnBg,
                            borderRadius: BorderRadius.circular(10),
                            border: btnBorder,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: btnText,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),

              // Controles: Alternar Modo de Visualização e Correção Instantânea
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Toggle Caderno Contínuo vs Foco
                  Row(
                    children: [
                      ActionChip(
                        avatar: Icon(
                          _isFocusMode ? Icons.view_carousel_rounded : Icons.view_agenda_rounded,
                          size: 16,
                          color: AppTheme.orange,
                        ),
                        label: Text(
                          _isFocusMode ? 'Modo Foco' : 'Caderno Completo',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        onPressed: () {
                          setState(() {
                            _isFocusMode = !_isFocusMode;
                          });
                        },
                      ),
                    ],
                  ),
                  // Toggle Correção Instantânea
                  Row(
                    children: [
                      const Text(
                        'Correção Imediata',
                        style: TextStyle(fontSize: 11.5, color: AppTheme.mutedText),
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: _instantCorrection,
                        activeThumbColor: AppTheme.orange,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          setState(() {
                            _instantCorrection = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ========================================================
        // LISTA DE QUESTÕES (Caderno Completo ou Modo Foco)
        // ========================================================
        if (_isFocusMode) ...[
          // Modo Foco: Uma questão por vez com navegação
          Builder(
            builder: (context) {
              final qIndex = _currentFocusIndex;
              final question = _questions[qIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EnemQuestionCard(
                    key: ValueKey('focus-$qIndex'),
                    question: question,
                    selectedOption: _userAnswers[qIndex],
                    isConfirmed: _confirmedQuestions.contains(qIndex),
                    showExplanation: _expandedExplanations.contains(qIndex),
                    onSelectOption: (opt) => _selectOption(qIndex, opt),
                    onConfirmAnswer: () => _confirmAnswer(qIndex),
                    onToggleExplanation: () => _toggleExplanation(qIndex),
                  ),

                  // Navegação Anterior / Próxima Questão
                  Row(
                    children: [
                      if (qIndex > 0)
                        Expanded(
                          child: BouncingPressable(
                            onTap: () {
                              setState(() {
                                _currentFocusIndex--;
                              });
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceSoft,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.darkText),
                                  SizedBox(width: 6),
                                  Text(
                                    'Questão Anterior',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (qIndex > 0 && qIndex < totalQuestions - 1)
                        const SizedBox(width: 10),
                      if (qIndex < totalQuestions - 1)
                        Expanded(
                          child: BouncingPressable(
                            onTap: () {
                              setState(() {
                                _currentFocusIndex++;
                              });
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.orange,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Próxima Questão',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ] else ...[
          // Modo Caderno Contínuo: Todas as 10 questões exibidas na página
          ...List.generate(totalQuestions, (index) {
            final question = _questions[index];
            return Container(
              key: _questionKeys[index],
              child: EnemQuestionCard(
                question: question,
                selectedOption: _userAnswers[index],
                isConfirmed: _confirmedQuestions.contains(index),
                showExplanation: _expandedExplanations.contains(index),
                onSelectOption: (opt) => _selectOption(index, opt),
                onConfirmAnswer: () => _confirmAnswer(index),
                onToggleExplanation: () => _toggleExplanation(index),
              ),
            );
          }),
        ],
      ],
    );
  }
}
