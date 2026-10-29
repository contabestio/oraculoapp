import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/books_repository.dart';
import '../models/book_model.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

/// Modal / Painel exclusivo para Desenvolvedores inserirem e editarem
/// o conteúdo dos cartões de livros.
///
/// Este componente permite:
/// 1. Preencher título, categoria, capa, tempo de leitura e sinopse.
/// 2. Adicionar múltiplos capítulos/seções com conteúdo rico, dicas e pontos-chave.
/// 3. Salvar instantaneamente no app (persistido no dispositivo).
/// 4. Copiar como código Dart pronto para ser versionado no Git!
class DevBookEditorSheet extends StatefulWidget {
  final BookModel? bookToEdit;

  const DevBookEditorSheet({
    super.key,
    this.bookToEdit,
  });

  static Future<void> show(BuildContext context, {BookModel? book}) {
    if (!AdminService.instance.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas contas de Administrador podem inserir ou editar livros.'),
          backgroundColor: AppTheme.deleteRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return Future.value();
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DevBookEditorSheet(bookToEdit: book),
    );
  }

  @override
  State<DevBookEditorSheet> createState() => _DevBookEditorSheetState();
}

class _DevBookEditorSheetState extends State<DevBookEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _readTimeController;
  late final TextEditingController _authorController;
  late final TextEditingController _tagsController;

  late List<_SectionDraft> _sections;

  // Sugestões de capas com imagens de alta qualidade para facilitar o teste do dev
  static const List<Map<String, String>> _coverPresets = [
    {
      'label': 'Caderno & Caneta',
      'url': 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&q=80',
    },
    {
      'label': 'Livros Antigos',
      'url': 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&q=80',
    },
    {
      'label': 'Fórmulas & Exatas',
      'url': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80',
    },
    {
      'label': 'Geometria & Lousa',
      'url': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
    },
    {
      'label': 'Biblioteca Clássica',
      'url': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
    },
    {
      'label': 'Laboratório & Ciências',
      'url': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400&q=80',
    },
    {
      'label': 'Microscópio & Bio',
      'url': 'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=400&q=80',
    },
  ];

  static const List<String> _categories = [
    'Redação',
    'Matemática',
    'Linguagens',
    'Ciências',
    'Humanas',
    'Atualidades',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.bookToEdit;

    _idController = TextEditingController(
      text: b?.id ?? 'livro-${DateTime.now().millisecondsSinceEpoch}',
    );
    _titleController = TextEditingController(text: b?.title ?? '');
    _categoryController = TextEditingController(text: b?.category ?? 'Redação');
    _imageUrlController = TextEditingController(
      text: b?.imageUrl ?? _coverPresets.first['url']!,
    );
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _readTimeController = TextEditingController(
      text: (b?.readTimeMinutes ?? 10).toString(),
    );
    _authorController = TextEditingController(
      text: b?.author ?? 'Equipe Oráculo',
    );
    _tagsController = TextEditingController(text: b?.tags.join(', ') ?? '');

    if (b != null && b.sections.isNotEmpty) {
      _sections = b.sections.map((s) => _SectionDraft.fromSection(s)).toList();
    } else {
      _sections = [
        _SectionDraft(
          id: 'sec-1',
          titleController: TextEditingController(text: '1. Introdução'),
          contentController: TextEditingController(
            text: 'Escreva aqui o conteúdo explicativo deste capítulo...',
          ),
          tipController: TextEditingController(
            text: 'Dica prática ou pegadinha comum em provas.',
          ),
          takeawaysController: TextEditingController(
            text: 'Conceito principal\nExemplo importante\nResumo prático',
          ),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _readTimeController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    for (final s in _sections) {
      s.dispose();
    }
    super.dispose();
  }

  BookModel _buildBookFromForm() {
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final sections = _sections.map((s) => s.toSection()).toList();

    return BookModel(
      id: _idController.text.trim().isEmpty
          ? 'livro-${DateTime.now().millisecondsSinceEpoch}'
          : _idController.text.trim(),
      title: _titleController.text.trim().isEmpty
          ? 'Novo Material'
          : _titleController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'Geral'
          : _categoryController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      description: _descriptionController.text.trim(),
      readTimeMinutes: int.tryParse(_readTimeController.text.trim()) ?? 10,
      author: _authorController.text.trim().isEmpty
          ? 'Equipe Oráculo'
          : _authorController.text.trim(),
      tags: tags,
      sections: sections,
      isCustom: true,
    );
  }

  Future<void> _saveToApp() async {
    final book = _buildBookFromForm();
    await BooksRepository.instance.saveBook(book);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Livro "${book.title}" salvo com sucesso no app!'),
        backgroundColor: AppTheme.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _copyAsDartCode() async {
    final book = _buildBookFromForm();
    final dartCode = book.toDartCode();
    await Clipboard.setData(ClipboardData(text: dartCode));
    if (!mounted) return;

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
            const Text(
              'O código deste livro está na sua área de transferência.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Para adicioná-lo permanentemente ao app para TODOS os usuários:',
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
                '1. Abra o arquivo:\nlib/data/universal_books_catalog.dart\n\n2. Cole o código copiado dentro da lista universalBooksCatalog.',
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
  }

  void _addSection() {
    setState(() {
      final index = _sections.length + 1;
      _sections.add(
        _SectionDraft(
          id: 'sec-$index',
          titleController: TextEditingController(text: '$index. Novo Capítulo'),
          contentController: TextEditingController(),
          tipController: TextEditingController(),
          takeawaysController: TextEditingController(),
        ),
      );
    });
  }

  void _removeSection(int index) {
    if (_sections.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O livro precisa de pelo menos 1 seção.')),
      );
      return;
    }
    setState(() {
      final removed = _sections.removeAt(index);
      removed.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookToEdit != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Barra de Arraste Superior
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Cabeçalho DEV
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.terminal, color: Color(0xFF38BDF8), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'DEV MODE',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEditing ? 'Editar Conteúdo do Livro' : 'Inserir Novo Livro',
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.mutedText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Formulário com Rolagem
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aviso informativo ao desenvolvedor
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.orangeBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.orangeDark, size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Preencha as informações para testar no app ou use os botões para copiar o código pronto para colar em universal_books_catalog.dart.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.darkText,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      const ClipboardData(text: BookTemplates.fullBookTemplate),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Template de livro copiado! Pronto para colar no código.'),
                                        backgroundColor: Color(0xFF2E7D32),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.content_copy_rounded, size: 16),
                                  label: const Text('Copiar Template em Branco'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.darkPurple,
                                    backgroundColor: AppTheme.lilac.withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Título do Livro
                    _buildLabel('Título do Livro / Material *'),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Ex: Redação Nota 1000, Geometria Analítica...',
                      icon: Icons.menu_book,
                    ),
                    const SizedBox(height: 14),

                    // Categoria
                    _buildLabel('Matéria / Categoria *'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _categoryController.text == cat;
                        return BouncingPressable(
                          onTap: () {
                            setState(() {
                              _categoryController.text = cat;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.orange
                                  : AppTheme.orangeBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.orange,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // URL da Capa e Presets
                    _buildLabel('URL da Imagem da Capa'),
                    _buildTextField(
                      controller: _imageUrlController,
                      hint: 'https://images.unsplash.com/...',
                      icon: Icons.image_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),

                    // Sugestões rápidas de capas
                    const Text(
                      'Sugestões rápidas de capa:',
                      style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _coverPresets.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final p = _coverPresets[index];
                          return BouncingPressable(
                            onTap: () {
                              setState(() {
                                _imageUrlController.text = p['url']!;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceSoft,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                p['label']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sinopse / Descrição Geral
                    _buildLabel('Sinopse / Descrição Breve'),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Resumo do que o estudante vai aprender com este livro...',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),

                    // Tempo estimado de leitura e Autor
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Tempo Leitura (min)'),
                              _buildTextField(
                                controller: _readTimeController,
                                hint: '15',
                                icon: Icons.timer_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Autor / Curadoria'),
                              _buildTextField(
                                controller: _authorController,
                                hint: 'Equipe Oráculo',
                                icon: Icons.person_outline,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tags
                    _buildLabel('Tags de Busca (separadas por vírgula)'),
                    _buildTextField(
                      controller: _tagsController,
                      hint: 'redação, dissertação, nota 1000, enem',
                      icon: Icons.tag,
                    ),
                    const SizedBox(height: 24),

                    // ========================================================
                    // SEÇÕES / CAPÍTULOS DO CONTEÚDO
                    // ========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Capítulos & Conteúdo',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        BouncingPressable(
                          onTap: _addSection,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lilac,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16, color: AppTheme.darkPurple),
                                SizedBox(width: 4),
                                Text(
                                  '+ Capítulo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Lista de Capítulos
                    ...List.generate(_sections.length, (index) {
                      final s = _sections[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5D9FA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Capítulo ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.darkText,
                                    ),
                                  ),
                                ),
                                if (_sections.length > 1)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppTheme.deleteRed,
                                      size: 20,
                                    ),
                                    onPressed: () => _removeSection(index),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildLabel('Título do Capítulo'),
                            _buildTextField(
                              controller: s.titleController,
                              hint: 'Ex: 1. Introdução e Tese',
                            ),
                            const SizedBox(height: 10),
                            _buildLabel('Conteúdo do Capítulo (Texto Completo)'),
                            _buildTextField(
                              controller: s.contentController,
                              hint: 'Escreva a matéria, explicações, fórmulas e exemplos...',
                              maxLines: 6,
                            ),
                            const SizedBox(height: 10),
                            _buildLabel('Dica de Ouro / Atenção (Opcional)'),
                            _buildTextField(
                              controller: s.tipController,
                              hint: 'Ex: Cuidado com conectivos causais...',
                              icon: Icons.lightbulb_outline,
                            ),
                            const SizedBox(height: 10),
                            _buildLabel('Pontos-chave (1 por linha)'),
                            _buildTextField(
                              controller: s.takeawaysController,
                              hint: 'Ponto 1\nPonto 2\nPonto 3',
                              icon: Icons.checklist_rounded,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // ========================================================
                    // BOTÕES DE AÇÃO DO DESENVOLVEDOR
                    // ========================================================
                    Row(
                      children: [
                        // Copiar Código Dart
                        Expanded(
                          child: BouncingPressable(
                            onTap: _copyAsDartCode,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.code_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Copiar p/ Código',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Salvar no App
                        Expanded(
                          child: BouncingPressable(
                            onTap: _saveToApp,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.orange,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.orange.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Salvar no App',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (isEditing) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Excluir livro?'),
                                content: const Text(
                                  'Se este for um livro original, ele voltará ao conteúdo original. Se foi criado por você, será removido.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Excluir',
                                      style: TextStyle(color: AppTheme.deleteRed),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await BooksRepository.instance.deleteBook(widget.bookToEdit!.id);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.delete_outline, color: AppTheme.deleteRed),
                          label: const Text(
                            'Excluir / Restaurar Original',
                            style: TextStyle(color: AppTheme.deleteRed),
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: maxLines > 1 ? 10 : 2,
      ),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
              child: Icon(icon, color: AppTheme.mutedText, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13, color: AppTheme.darkText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDraft {
  final String id;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController tipController;
  final TextEditingController takeawaysController;

  _SectionDraft({
    required this.id,
    required this.titleController,
    required this.contentController,
    required this.tipController,
    required this.takeawaysController,
  });

  factory _SectionDraft.fromSection(BookSectionModel section) {
    return _SectionDraft(
      id: section.id,
      titleController: TextEditingController(text: section.title),
      contentController: TextEditingController(text: section.content),
      tipController: TextEditingController(text: section.studyTip ?? ''),
      takeawaysController: TextEditingController(
        text: section.keyTakeaways.join('\n'),
      ),
    );
  }

  BookSectionModel toSection() {
    final takeaways = takeawaysController.text
        .split('\n')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return BookSectionModel(
      id: id,
      title: titleController.text.trim().isEmpty
          ? 'Capítulo'
          : titleController.text.trim(),
      content: contentController.text.trim(),
      studyTip: tipController.text.trim().isEmpty
          ? null
          : tipController.text.trim(),
      keyTakeaways: takeaways,
    );
  }

  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tipController.dispose();
    takeawaysController.dispose();
  }
}
