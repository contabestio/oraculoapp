import 'package:flutter/material.dart';
import 'book_cover_card.dart';

class MaterialBook {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const MaterialBook({
    required this.title,
    required this.imageUrl,
    this.onTap,
  });
}

class MeusMateriaisSection extends StatelessWidget {
  final List<MaterialBook> books;

  const MeusMateriaisSection({
    super.key,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Meus Materiais',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 170,
            childAspectRatio: 0.58,
            crossAxisSpacing: 24,
            mainAxisSpacing: 28,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return BookCoverCard(
              title: book.title,
              imageUrl: book.imageUrl,
              onTap: book.onTap ?? () {},
            );
          },
        ),
      ],
    );
  }
}