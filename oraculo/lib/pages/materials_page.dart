import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/book_cover_card.dart';

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

  // Coleção completa de materiais de estudo do Oráculo
  final List<Map<String, String>> _allMaterials = [
    {
      'title': 'Redação Nota 1000',
      'category': 'Redação',
      'image':
          'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&q=80',
    },
    {
      'title': 'Estrutura Argumentativa',
      'category': 'Redação',
      'image':
          'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&q=80',
    },
    {
      'title': 'Matemática e Funções',
      'category': 'Matemática',
      'image':
          'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80',
    },
    {
      'title': 'Geometria Espacial',
      'category': 'Matemática',
      'image':
          'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
    },
    {
      'title': 'Literatura e Clássicos',
      'category': 'Linguagens',
      'image':
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
    },
    {
      'title': 'Gramática e Interpretação',
      'category': 'Linguagens',
      'image':
          'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80',
    },
    {
      'title': 'Física Mecânica & Óptica',
      'category': 'Ciências',
      'image':
          'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400&q=80',
    },
    {
      'title': 'Química Geral & Orgânica',
      'category': 'Ciências',
      'image':
          'https://images.unsplash.com/photo-1603126857599-f6e157fa2fe6?w=400&q=80',
    },
    {
      'title': 'Biologia Celular e Genética',
      'category': 'Ciências',
      'image':
          'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=400&q=80',
    },
    {
      'title': 'História do Brasil',
      'category': 'Humanas',
      'image':
          'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80',
    },
    {
      'title': 'Filosofia e Sociologia',
      'category': 'Humanas',
      'image':
          'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400&q=80',
    },
  ];

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

    final filteredList = _allMaterials.where((item) {
      final matchesCategory = _selectedCategory == 'Todos' ||
          item['category'] == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          (item['title']?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (item['category']?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
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
                ],
              ),
            ),

            // ======================================================
            // CAMPO DE BUSCA ORIGINAL
            // ======================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            // GRADE COMPLETA DE MATERIAIS COM ANIMAÇÃO
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
                          return BookCoverCard(
                            title: item['title'] ?? '',
                            imageUrl: item['image'] ?? '',
                            onTap: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Abrindo: ${item['title']}'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
