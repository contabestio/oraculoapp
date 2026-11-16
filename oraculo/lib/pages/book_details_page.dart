import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/books_repository.dart';
import '../models/book_model.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/book_cover_card.dart';
import '../widgets/book_simulado_tab.dart';
import '../widgets/dev_book_editor_sheet.dart';
import 'notes_and_insights_page.dart';
import 'package:oraculo/widgets/formatted_book_content.dart';

/// Tela de Leitura e Conteúdo do Livro (Material de Estudo)
///
/// Usuários regulares podem apenas visualizar e navegar pelos capítulos.
/// Desenvolvedores (em Debug Mode ou com acesso DEV) podem editar o conteúdo
/// e exportar como código Dart diretamente desta tela.
class BookDetailsPage extends StatefulWidget {
  final BookModel initialBook;

  const BookDetailsPage({
    super.key,
    required this.initialBook,
  });

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late String _bookId;
  int _currentSectionIndex = 0;
  int _activeTabIndex = 0; // 0 = Conteúdo/Teoria, 1 = Simulado ENEM
  final ScrollController _scrollController = ScrollController();
  double _readingFontSize = 15.0;

  @override
  void initState() {
    super.initState();
    _bookId = widget.initialBook.id;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BookModel>>(
      valueListenable: BooksRepository.instance.booksNotifier,
      builder: (context, books, _) {
        final book = books.firstWhere(
          (b) => b.id == _bookId,
          orElse: () => widget.initialBook,
        );

        final sections = book.sections;
        final hasSections = sections.isNotEmpty;
        final currentSection = hasSections
            ? sections[_currentSectionIndex.clamp(0, sections.length - 1)]
            : null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: BouncingPressable(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: AppTheme.orange, size: 22),
              ),
            ),
            title: Text(
              book.title,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              // BOTÃO DE ACESSO DIRETO AO CADERNO DE NOTAS E INSIGHTS
              IconButton(
                tooltip: 'Caderno de Notas e Insights',
                icon: const Icon(
                  Icons.note_alt_outlined,
                  color: Color(0xFF594A6D),
                  size: 22,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotesAndInsightsPage(
                        initialBookTitle: book.title,
                        initialBookId: book.id,
                      ),
                    ),
                  );
                },
              ),
              // BOTAO DE EDICAO: Apenas visível para contas de Administrador (inacessível a usuários regulares)
              if (AdminService.instance.isAdmin) ...[
                IconButton(
                  tooltip: 'Copiar Código p/ Catálogo Universal',
                  icon: const Icon(Icons.code_rounded, color: AppTheme.mutedText, size: 20),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: book.toDartCode()));
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                            SizedBox(width: 8),
                            Text('Código Copiado!'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'O código de "${book.title}" foi copiado!',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Para torná-lo permanente para todos os usuários:\nCole dentro de universalBooksCatalog em lib/data/universal_books_catalog.dart.',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Editar Conteúdo (Admin)',
                  icon: const Icon(Icons.edit_note_rounded, color: AppTheme.orangeDark, size: 24),
                  onPressed: () => DevBookEditorSheet.show(context, book: book),
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========================================================
                // CABEÇALHO DO LIVRO COM CAPA E RESUMO
                // ========================================================
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSoft,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF0EAE1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Miniatura 3D da Capa
                      SizedBox(
                        width: 95,
                        height: 140,
                        child: BookCoverCard(
                          title: '',
                          imageUrl: book.imageUrl,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Detalhes textuais
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categoria e tempo de leitura
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.orangeBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    book.category,
                                    style: const TextStyle(
                                      color: AppTheme.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 12, color: AppTheme.mutedText),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${book.readTimeMinutes} min',
                                        style: const TextStyle(
                                          color: AppTheme.darkText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkText,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Por ${book.author}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.mutedText,
                              ),
                            ),
                            if (book.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                book.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF555555),
                                  height: 1.35,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ========================================================
                // SELETOR DE ABAS: TEORIA & LEITURA vs SIMULADO ENEM
                // ========================================================
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Aba 1: Teoria & Leitura
                      Expanded(
                        child: BouncingPressable(
                          onTap: () {
                            if (_activeTabIndex != 0) {
                              setState(() {
                                _activeTabIndex = 0;
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTabIndex == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTabIndex == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                  color: _activeTabIndex == 0 ? AppTheme.orange : AppTheme.mutedText,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Teoria & Leitura',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 13,
                                    fontWeight: _activeTabIndex == 0 ? FontWeight.bold : FontWeight.w600,
                                    color: _activeTabIndex == 0 ? AppTheme.darkText : AppTheme.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Aba 2: Simulado ENEM
                      Expanded(
                        child: BouncingPressable(
                          onTap: () {
                            if (_activeTabIndex != 1) {
                              setState(() {
                                _activeTabIndex = 1;
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTabIndex == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTabIndex == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 16,
                                  color: _activeTabIndex == 1 ? AppTheme.orange : AppTheme.mutedText,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Simulado ENEM',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 13,
                                    fontWeight: _activeTabIndex == 1 ? FontWeight.bold : FontWeight.w600,
                                    color: _activeTabIndex == 1 ? AppTheme.darkText : AppTheme.mutedText,
                                  ),
                                ),
                                if (book.questions.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: _activeTabIndex == 1 ? AppTheme.orange : const Color(0xFFE2E2EA),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${book.questions.length}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: _activeTabIndex == 1 ? Colors.white : const Color(0xFF666666),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ========================================================
                // CONTEÚDO CONDICIONAL (TEORIA vs SIMULADO)
                // ========================================================
                if (_activeTabIndex == 1) ...[
                  BookSimuladoTab(book: book),
                ] else ...[
                  // ========================================================
                  // ATALHO PARA O CADERNO DE NOTAS DO LIVRO
                  // ========================================================
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F0FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEADBFF)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF594A6D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Caderno de Notas & Insights',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: Color(0xFF3B2A56),
                                ),
                              ),
                              Text(
                                'Anote seus resumos e dúvidas sobre este livro',
                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        BouncingPressable(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotesAndInsightsPage(
                                  initialBookTitle: book.title,
                                  initialBookId: book.id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF594A6D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Anotar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ========================================================
                // SELETOR DE CAPÍTULOS / TÓPICOS
                // ========================================================
                if (sections.length > 1) ...[
                  const Text(
                    'Capítulos de Estudo',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: sections.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final sec = sections[index];
                        final isSelected = _currentSectionIndex == index;
                        return BouncingPressable(
                          onTap: () {
                            setState(() {
                              _currentSectionIndex = index;
                            });
                            _scrollToTop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.orange : AppTheme.orangeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                sec.title.split('.').last.trim(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.orange,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ========================================================
                // CONTEÚDO DO CAPÍTULO ATUAL
                // ========================================================
                if (currentSection != null) ...[
                  // Título do Capítulo e Controles de Leitura
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          currentSection.title,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTextHeading,
                            height: 1.3,
                          ),
                        ),
                      ),
                      // Controles de Leitura e Tamanho do Texto
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0EAE1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BouncingPressable(
                              onTap: () {
                                if (_readingFontSize > 12.5) {
                                  setState(() => _readingFontSize -= 1.0);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: const Text(
                                  'A-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppTheme.darkText,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 12,
                              width: 1,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            BouncingPressable(
                              onTap: () {
                                if (_readingFontSize < 19.5) {
                                  setState(() => _readingFontSize += 1.0);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: const Text(
                                  'A+',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppTheme.orangeDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Corpo do Texto Formatado com Quebras e Negrito
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFF0EAE1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FormattedBookContent(
                      content: currentSection.content,
                      fontSize: _readingFontSize,
                    ),
                  ),

                  // DICA DE OURO / DESTAQUE (se houver)
                  if (currentSection.studyTip != null && currentSection.studyTip!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lilacNotes,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.lilacContainer),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lightbulb_rounded,
                              color: Color(0xFF6B46C1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dica de Ouro Oráculo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF4C1D95),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentSection.studyTip!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.darkText,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // PONTOS-CHAVE / TAKEAWAYS (se houver)
                  if (currentSection.keyTakeaways.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.orangeBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.orange.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.checklist_rounded, color: AppTheme.orangeDark, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Pontos-chave para Lembrar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.orangeDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...currentSection.keyTakeaways.map((point) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: AppTheme.orangeDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.darkText,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // NAVEGAÇÃO ENTRE CAPÍTULOS
                  Row(
                    children: [
                      if (_currentSectionIndex > 0)
                        Expanded(
                          child: BouncingPressable(
                            onTap: () {
                              setState(() {
                                _currentSectionIndex--;
                              });
                              _scrollToTop();
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceSoft,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.darkText),
                                  SizedBox(width: 6),
                                  Text(
                                    'Anterior',
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
                      if (_currentSectionIndex > 0 && _currentSectionIndex < sections.length - 1)
                        const SizedBox(width: 12),
                      if (_currentSectionIndex < sections.length - 1)
                        Expanded(
                          child: BouncingPressable(
                            onTap: () {
                              setState(() {
                                _currentSectionIndex++;
                              });
                              _scrollToTop();
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppTheme.orange,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.orange.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Próximo Capítulo',
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
                      if (_currentSectionIndex == sections.length - 1)
                        Expanded(
                          child: BouncingPressable(
                            onTap: () {
                              if (book.questions.isNotEmpty) {
                                setState(() {
                                  _activeTabIndex = 1;
                                });
                                _scrollToTop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.celebration_rounded, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text('Parabéns! Leitura concluída.'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF2E7D32),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: book.questions.isNotEmpty ? AppTheme.orange : const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (book.questions.isNotEmpty ? AppTheme.orange : const Color(0xFF2E7D32))
                                        .withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    book.questions.isNotEmpty ? 'Fazer Simulado ENEM' : 'Concluir Leitura',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    book.questions.isNotEmpty ? Icons.arrow_forward_rounded : Icons.check_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  // Caso o livro ainda não tenha seções cadastradas
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 48, color: AppTheme.mutedText),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum capítulo cadastrado ainda.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                          if (book.questions.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _activeTabIndex = 1;
                                });
                              },
                              icon: const Icon(Icons.assignment_outlined),
                              label: Text('Acessar Simulado ENEM (${book.questions.length} Questões)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ],
                          if (AdminService.instance.isAdmin) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => DevBookEditorSheet.show(context, book: book),
                              icon: const Icon(Icons.add),
                              label: const Text('Inserir Conteúdo (Admin)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.surfaceSoft,
                                foregroundColor: AppTheme.darkText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ], // Fecha o else do _activeTabIndex
              ],
            ),
          ),
        );
      },
    );
  }
}
