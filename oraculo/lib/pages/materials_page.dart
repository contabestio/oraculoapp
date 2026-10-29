import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/books_repository.dart';
import '../models/book_model.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_management_dialog.dart';
import '../widgets/animations.dart';
import '../widgets/book_cover_card.dart';
import '../widgets/dev_book_editor_sheet.dart';
import 'book_details_page.dart';

class MaterialsPage extends StatefulWidget {
  final String initialQuery;

  const MaterialsPage({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  late final TextEditingController _searchController;
  late String _searchQuery;
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery.trim();
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Todos',
      'Redação',
      'Matemática',
      'Linguagens',
      'Ciências',
      'Humanas'
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: AdminService.instance.isAdminNotifier,
      builder: (context, isAdmin, _) {
        return ValueListenableBuilder<List<BookModel>>(
          valueListenable: BooksRepository.instance.booksNotifier,
          builder: (context, allBooks, _) {
            final filteredList = allBooks.where((item) {
              final matchesCategory = _selectedCategory == 'Todos' ||
                  item.category.toLowerCase() == _selectedCategory.toLowerCase();
              final matchesQuery = _searchQuery.isEmpty ||
                  item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  item.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
              return matchesCategory && matchesQuery;
            }).toList();

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    // ======================================================
                    // BARRA SUPERIOR COM CORES ORIGINAIS
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          BouncingPressable(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppTheme.orange,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Coleção de Materiais',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: AppTheme.darkText,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.orangeBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${filteredList.length} itens',
                              style: const TextStyle(
                                color: AppTheme.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // MENU DE ADMINISTRADOR (Apenas visível se o usuário for ADMIN)
                          if (isAdmin) ...[
                            const SizedBox(width: 6),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: AppTheme.darkText,
                                size: 22,
                              ),
                              tooltip: 'Opções de Admin',
                              onSelected: (value) async {
                                if (value == 'manage_admins') {
                                  AdminManagementDialog.show(context);
                                } else if (value == 'copy_book_template') {
                                  await Clipboard.setData(const ClipboardData(text: BookTemplates.fullBookTemplate));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Template de livro completo copiado! Pronto para colar no código.'),
                                      backgroundColor: Color(0xFF2E7D32),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else if (value == 'copy_section_template') {
                                  await Clipboard.setData(const ClipboardData(text: BookTemplates.sectionTemplate));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Template de capítulo copiado! Pronto para colar no código.'),
                                      backgroundColor: Color(0xFF2E7D32),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else if (value == 'copy_quick_template') {
                                  await Clipboard.setData(const ClipboardData(text: BookTemplates.quickBookTemplate));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Template de livro rápido (5 linhas) copiado!'),
                                      backgroundColor: Color(0xFF2E7D32),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else if (value == 'export_dart') {
                                  final code = BooksRepository.instance.exportCompleteCatalogFile();
                                  await Clipboard.setData(ClipboardData(text: code));
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: const Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                                          SizedBox(width: 8),
                                          Text('Catálogo Exportado!'),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'O código completo do catálogo de livros foi copiado para a área de transferência.',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Para aplicar permanentemente para TODOS os usuários:',
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceSoft,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: const Text(
                                              '1. Abra o arquivo:\nlib/data/universal_books_catalog.dart\n\n2. Selecione tudo e cole o conteúdo copiado.',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                color: AppTheme.darkText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Entendido!'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (value == 'reset_defaults') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Restaurar Padrões?'),
                                      content: const Text(
                                        'Isso removerá todas as alterações e livros criados em dev/admin mode.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Restaurar',
                                            style: TextStyle(color: AppTheme.deleteRed),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await BooksRepository.instance.resetToDefaults();
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'manage_admins',
                                  child: Row(
                                    children: [
                                      Icon(Icons.shield_outlined,
                                          size: 18, color: Color(0xFF38BDF8)),
                                      SizedBox(width: 8),
                                      Text('Gerenciar Admins'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'copy_book_template',
                                  child: Row(
                                    children: [
                                      Icon(Icons.content_copy_rounded,
                                          size: 18, color: AppTheme.orange),
                                      SizedBox(width: 8),
                                      Text('Copiar Template de Livro'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'copy_section_template',
                                  child: Row(
                                    children: [
                                      Icon(Icons.menu_book_rounded,
                                          size: 18, color: AppTheme.darkPurple),
                                      SizedBox(width: 8),
                                      Text('Copiar Template de Capítulo'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'copy_quick_template',
                                  child: Row(
                                    children: [
                                      Icon(Icons.flash_on_rounded,
                                          size: 18, color: Color(0xFFF59E0B)),
                                      SizedBox(width: 8),
                                      Text('Copiar Livro Rápido (5 linhas)'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'export_dart',
                                  child: Row(
                                    children: [
                                      Icon(Icons.code_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text('Exportar Tudo em Dart'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'reset_defaults',
                                  child: Row(
                                    children: [
                                      Icon(Icons.restart_alt_rounded,
                                          size: 18, color: AppTheme.deleteRed),
                                      SizedBox(width: 8),
                                      Text(
                                        'Restaurar Padrões',
                                        style: TextStyle(color: AppTheme.deleteRed),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ======================================================
                    // BARRA DO ADMINISTRADOR (Apenas visível se o usuário for ADMIN)
                    // ======================================================
                    if (isAdmin)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Color(0xFF38BDF8),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Painel Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              BouncingPressable(
                                onTap: () => AdminManagementDialog.show(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.people_outline,
                                          size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Admins',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              BouncingPressable(
                                onTap: () => DevBookEditorSheet.show(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded,
                                          size: 16, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Inserir Conteúdo',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ======================================================
                    // CAMPO DE BUSCA ORIGINAL
                    // ======================================================
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE5D9FA),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppTheme.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.trim();
                                  });
                                },
                                style: const TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Pesquise por matéria ou tema...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              BouncingPressable(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF8E8E8E),
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ======================================================
                    // CHIPS DE CATEGORIAS
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = _selectedCategory == cat;

                            return BouncingPressable(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.orange
                                      : AppTheme.orangeBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.orange,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ======================================================
                    // GRADE COMPLETA DE MATERIAIS COM LEITURA REAL
                    // ======================================================
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.orangeBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.search,
                                      size: 40,
                                      color: AppTheme.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Nenhum material encontrado',
                                    style: TextStyle(
                                      color: AppTheme.darkText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tente buscar por outro termo ou categoria',
                                    style: TextStyle(
                                      color: Color(0xFF8E8E8E),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : FadeSlideTransition(
                              delay: const Duration(milliseconds: 100),
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.60,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 22,
                                ),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final item = filteredList[index];
                                  return Stack(
                                    children: [
                                      // Cartão do livro clicável (Abre a página de leitura para qualquer usuário)
                                      Positioned.fill(
                                        child: BookCoverCard(
                                          title: item.title,
                                          imageUrl: item.imageUrl,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookDetailsPage(
                                                        initialBook: item),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // Botão de atalho rápido de edição (Visível APENAS para contas de Administrador)
                                      if (isAdmin)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: BouncingPressable(
                                            onTap: () => DevBookEditorSheet.show(
                                              context,
                                              book: item,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E293B)
                                                    .withValues(alpha: 0.85),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.edit_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
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
}
