import 'package:booklisting_app_client/entities/BookLink.dart';

import 'Author.dart';

class Book
{
  Book({required this.id, required this.title, required this.author, required this.bookLinks, required this.coverImagePath});

  final int id;
  final String title;
  final Author author;
  final String coverImagePath;
  final List<BookLink> bookLinks;

}