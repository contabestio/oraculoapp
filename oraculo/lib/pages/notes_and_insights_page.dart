import 'package:flutter/material.dart';

class NotesAndInsightsPage extends StatelessWidget {
  /// Lista de caminhos de imagens locais (ex: 'assets/images/note1.png')
  /// ou URLs de rede (ex: 'https://...').
  final List<String> noteImagePaths;

  const NotesAndInsightsPage({
    super.key,
    this.noteImagePaths = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ==========================================================
              // BARRA SUPERIOR (Botão de Fechar + Pill "Metas")
              // ==========================================================
              Row(
                children: [
                  // Botão 'X' para fechar
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFFFFB08E),
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(width: 16),

                  // Botão de pílula "Metas"
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB08E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.outlined_flag,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Metas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ==========================================================
              // CARD PRINCIPAL LILÁS (Notas e Insights)
              // ==========================================================
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADBFF),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Text(
                        'Notas e Insights >',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Grid de Cards Brancos / Imagens
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: noteImagePaths.length > 6
                              ? noteImagePaths.length
                              : 6, // Garante ao menos 6 cards como no layout
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                          itemBuilder: (context, index) {
                            final String? imagePath =
                                index < noteImagePaths.length
                                    ? noteImagePaths[index]
                                    : null;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: imagePath != null
                                  ? _buildNoteImage(imagePath)
                                  : const SizedBox.shrink(),
                            );
                          },
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
    );
  }

  /// Utilitário para renderizar tanto imagens de Assets locais quanto URLs
  Widget _buildNoteImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(
          Icons.broken_image,
          color: Colors.grey,
        ),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );
  }
}