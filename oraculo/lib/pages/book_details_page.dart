import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/books_repository.dart';
import '../models/book_model.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/book_cover_card.dart';
import '../widgets/dev_book_editor_sheet.dart';

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
  final ScrollController _scrollController = ScrollController();

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
                  // Título do Capítulo
                  Text(
                    currentSection.title,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextHeading,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Corpo do Texto Formatado
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF2F2F5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      currentSection.content,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14.5,
                        color: Color(0xFF333333),
                        height: 1.65,
                      ),
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
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Concluir Leitura',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
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
                          if (AdminService.instance.isAdmin) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => DevBookEditorSheet.show(context, book: book),
                              icon: const Icon(Icons.add),
                              label: const Text('Inserir Conteúdo (Admin)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
