import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/simulado_score_model.dart';
import '../services/simulado_score_service.dart';
import '../pages/notes_and_insights_page.dart';
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

  Future<void> _showResultSummary({bool isEarlyFinish = false}) async {
    int correctCount = 0;
    for (final index in _confirmedQuestions) {
      if (_userAnswers[index] == _questions[index].correctOptionIndex) {
        correctCount++;
      }
    }
    final total = isEarlyFinish ? _confirmedQuestions.length : _questions.length;
    final percentage = total > 0 ? ((correctCount / total) * 100).round() : 0;

    // Gravação da pontuação na tabela do Banco de Dados (Cloud Firestore & Local)
    try {
      await SimuladoScoreService.instance.recordScore(
        bookId: widget.book.id,
        bookTitle: widget.book.title,
        category: widget.book.category,
        score: correctCount,
        totalQuestions: _questions.length,
        answeredCount: _confirmedQuestions.length,
        userAnswers: _userAnswers,
      );
    } catch (e) {
      debugPrint('Erro ao registrar pontuação no banco: $e');
    }

    if (!mounted) return;

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
            Text(
              isEarlyFinish ? 'Simulado Parcial Finalizado!' : 'Simulado Finalizado!',
              style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold, fontSize: 18),
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
            const SizedBox(height: 12),

            // Confirmação de persistência na tabela do Banco de Dados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_done_rounded, color: Color(0xFF2E7D32), size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Pontuação salva no banco de dados!',
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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

  void _showAttemptsHistoryDialog(List<SimuladoScoreModel> attempts) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.history_rounded, color: Color(0xFF1D4ED8), size: 24),
            SizedBox(width: 8),
            Text(
              'Histórico de Pontuações',
              style: TextStyle(fontFamily: 'Arial', fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registros salvos no banco de dados para "${widget.book.title}":',
                style: const TextStyle(fontSize: 12.5, color: AppTheme.mutedText),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: attempts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = attempts[index];
                    final dateStr =
                        '${item.timestamp.day.toString().padLeft(2, '0')}/${item.timestamp.month.toString().padLeft(2, '0')}/${item.timestamp.year} às ${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';
                    final isPass = item.percentage >= 70;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: isPass ? const Color(0xFFE8F5E9) : AppTheme.orangeBg,
                        child: Text(
                          '${item.score}',
                          style: TextStyle(
                            color: isPass ? const Color(0xFF2E7D32) : AppTheme.orangeDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        '${item.score} de ${item.totalQuestions} acertos (${item.percentage.round()}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.mutedText),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_done_rounded, size: 12, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text('DB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
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
        // HISTÓRICO DE PONTUAÇÕES SALVAS NO BANCO DE DADOS
        // ========================================================
        ValueListenableBuilder<List<SimuladoScoreModel>>(
          valueListenable: SimuladoScoreService.instance.scoresNotifier,
          builder: (context, allScores, _) {
            final bookScores = allScores.where((s) => s.bookId == widget.book.id).toList();
            if (bookScores.isEmpty) return const SizedBox.shrink();

            final latest = bookScores.first;
            final best = bookScores.reduce((a, b) => a.score >= b.score ? a : b);

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Banco de Dados: Simulado Salvo',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: Color(0xFF14532D),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${bookScores.length} reg.',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Melhor: ${best.score}/${best.totalQuestions} (${best.percentage.round()}%) • Último: ${latest.score}/${latest.totalQuestions}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAttemptsHistoryDialog(bookScores),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      'Histórico',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

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

              // Controles: Alternar Modo, Atalho para Notas e Correção
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Toggle Caderno Contínuo vs Foco
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

                  // Atalho Direto para a Página de Notas
                  ActionChip(
                    avatar: const Icon(
                      Icons.edit_note_rounded,
                      size: 16,
                      color: Color(0xFF594A6D),
                    ),
                    label: const Text(
                      'Caderno de Notas',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF594A6D),
                      ),
                    ),
                    backgroundColor: const Color(0xFFF6F0FF),
                    side: const BorderSide(color: Color(0xFFEADBFF)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotesAndInsightsPage(
                            initialBookTitle: widget.book.title,
                            initialBookId: widget.book.id,
                          ),
                        ),
                      );
                    },
                  ),

                  // Botão de Gravar Pontuação Parcial no Banco
                  if (answeredCount > 0 && answeredCount < totalQuestions)
                    ActionChip(
                      avatar: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 16,
                        color: AppTheme.orangeDark,
                      ),
                      label: Text(
                        'Salvar Pontuação ($answeredCount/$totalQuestions)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.orangeDark),
                      ),
                      backgroundColor: AppTheme.orangeBg,
                      side: BorderSide(color: AppTheme.orange.withValues(alpha: 0.5)),
                      onPressed: () => _showResultSummary(isEarlyFinish: true),
                    ),

                  // Toggle Correção Instantânea
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
