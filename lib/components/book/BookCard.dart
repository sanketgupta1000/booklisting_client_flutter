import 'package:booklisting_app_client/services/book_service.dart';
import 'package:flutter/material.dart';

import '../../entities/Book.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.onTap, required this.jwt});

  // the book to display
  final Book book;

  // handle tap
  final VoidCallback onTap;

  final String jwt;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
          leading: Image.network(
            BookService.getCoverImageUrl(book.coverImagePath),
            headers: {
              "Authorization": "Bearer $jwt"
            },
            width: 100,
            height: 200,
          ),
          title: Text(book.title),
          subtitle: Text(book.author.fullName),
          onTap: onTap
      )
    );
  }
}
