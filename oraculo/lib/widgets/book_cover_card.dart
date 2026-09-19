import 'package:flutter/material.dart';

class BookCoverCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const BookCoverCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<BookCoverCard> createState() => _BookCoverCardState();
}

class _BookCoverCardState extends State<BookCoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                transform: _isHovered
                    ? (Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-0.35)
                      ..translate(0.0, -10.0, 0.0))
                    : Matrix4.identity(),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isHovered ? 0.35 : 0.12),
                      blurRadius: _isHovered ? 24 : 10,
                      offset: Offset(_isHovered ? -16 : 0, _isHovered ? 16 : 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Book Cover Art
                      Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE4D1FF),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 48,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),

                      // Book Spine Shadow & Crease Effect (Left side)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 18,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),

                      // Book Page Simulation (Right edge border)
                      Positioned(
                        right: 0,
                        top: 2,
                        bottom: 2,
                        width: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EAE1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Gloss / Sheen Layer
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.05),
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}