import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:booklisting_app_client/config.dart';
import 'package:booklisting_app_client/entities/Author.dart';
import 'package:booklisting_app_client/entities/BookLink.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

import '../entities/Book.dart';
import '../exceptions/exceptions.dart';

// all api communication logic related to books goes here

// function to get author obj from json
Author authorFromJson(Map<String, dynamic> jsonMap)
{
  return Author(
      id: jsonMap["id"] as int,
      email: jsonMap["email"] as String,
      fullName: jsonMap["fullName"] as String
  );
}

// function to get book link obj from json
BookLink bookLinkFromJson(Map<String, dynamic> jsonMap)
{
  return BookLink(
      id: jsonMap["id"] as int,
      name: jsonMap["linkName"] as String,
      link: jsonMap["link"] as String
  );
}

// function to get Book obj from json
Book bookFromJson(Map<String, dynamic> jsonMap)
{
  // get the author
  Author author = authorFromJson(jsonMap["author"] as Map<String, dynamic>);

  // get the list of links
  List<BookLink> links = (jsonMap["links"] as List)
                          .map((e)=>e as Map<String, dynamic>)
                          .map((linkMap)
      {
        return bookLinkFromJson(linkMap);
      })
      .toList();

  return Book(
    id: jsonMap["id"] as int,
    title: jsonMap["title"] as String,
    author: author,
    coverImagePath: jsonMap["coverImagePath"] as String,
    bookLinks: links
  );

}

// function to get json from book object
Map<String, dynamic> bookToJson(Book book)
{
  return {
    "id": book.id,
    "title": book.title,
    "links": book.bookLinks.map((link)=>
            {
              "linkName":link.name,
              "link": link.link
            })
            .toList()
  };
}

class BookService
{
  static const _addBookUrl = "/api/books";
  static const _getAllBooksUrl = "/api/books";
  static const _coverImageUrl = "/api/files?path=";
  static const _getBookUrl = "/api/books/";
  static const _updateBookUrl = "/api/books";
  static const _deleteBookUrl = "/api/books/";

  // method to add a book and return it
  static Future<Book> addBook({required Book book, required File coverImage, required String jwt}) async
  {
    final url = Uri.parse(Config.baseUrl+_addBookUrl);

    // new multi part request
    MultipartRequest request = MultipartRequest("POST", url);
    // headers
    Map<String, String> headers = {
      "Authorization": "Bearer $jwt",
    };

    print(bookToJson(book).toString());

    // set fields in request
    request.files.add(
      MultipartFile.fromString(
        'book',
        jsonEncode(bookToJson(book)),
        contentType: MediaType('application', 'json'),
      ),
    );
    request.files.add(
      await MultipartFile.fromPath(
      'cover_image',
      coverImage.path,
      contentType: MediaType('image', 'png'), // Update this if the image is a different type, like 'image/jpeg'
    ),);

    // add headers
    request.headers.addAll(headers);
    StreamedResponse streamedResponse;
    try
    {
      streamedResponse = await request.send();
    }
    catch(e)
    {
      // failed to send
      print(e);
      throw CommunicationException();
    }

    if(streamedResponse.statusCode==401)
    {
      // token has expired
      throw AuthenticationException();
    }
    else if(streamedResponse.statusCode!=200)
    {
      // unknown exception at server
      throw Exception();
    }

    // get the response obj
    Response response = await Response.fromStream(streamedResponse);

    // get book
    Map<String, dynamic> bookJson = jsonDecode(response.body);

    return bookFromJson(bookJson);
  }

  // method to get all books
  static Future<List<Book>> getAllBooks({required String jwt}) async
  {
    final url = Uri.parse(Config.baseUrl+_getAllBooksUrl);

    Response response;

    try
    {
      print("before get");
      response = await get(
        url,
        headers: {
          "Authorization": "Bearer $jwt"
        }
      );

      print("after get");

    }
    catch(e)
    {
      // failed to connect
      print(e.toString());
      throw CommunicationException();
    }
    if(response.statusCode==401)
    {
      // token expired
      throw AuthenticationException();
    }
    else if(response.statusCode!=200)
    {
      throw Exception();
    }

    List<Map<String, dynamic>> mapList = (jsonDecode(response.body) as List)
                                              .map((e)=>e as Map<String, dynamic>)
                                              .toList();

    List<Book> books = [];

    for (var map in mapList) {
      books.add(bookFromJson(map));
    }

    return books;

  }

  // method to get book image url from path
  static String getCoverImageUrl(String path)
  {
    return Config.baseUrl + _coverImageUrl +path;
  }

  // method to get a book by id
  static Future<Book> getBookById({required int id, required String jwt}) async
  {
    final url = Uri.parse(Config.baseUrl+_getBookUrl+id.toString());

    Response response;

    try
    {
      response = await get(
          url,
          headers: {
            "Authorization": "Bearer $jwt"
          }
      );
    }
    catch(e)
    {
      // failed to connect
      throw CommunicationException();
    }
    if(response.statusCode==401)
    {
      // token expired
      throw AuthenticationException();
    }
    else if(response.statusCode==404)
    {
      throw BookNotFoundException();
    }
    else if(response.statusCode!=200)
    {
      throw Exception();
    }

    Map<String, dynamic> bookJson = jsonDecode(response.body);

    return bookFromJson(bookJson);
  }

  // method to update a book
  static Future<Book> updateBook({required Book book, required String jwt, File? coverImage}) async
  {
    final url = Uri.parse(Config.baseUrl+_updateBookUrl);

    // new multi part request
    MultipartRequest request = MultipartRequest("PUT", url);
    // headers
    Map<String, String> headers = {
      "Authorization": "Bearer $jwt",
    };

    // set fields in request
    request.files.add(
      MultipartFile.fromString(
        'book',
        jsonEncode(bookToJson(book)),
        contentType: MediaType('application', 'json'),
      ),
    );
    if(coverImage!=null)
    {
      request.files.add(
        await MultipartFile.fromPath(
          'cover_image',
          coverImage.path,
          contentType: MediaType('image', 'png'), // Update this if the image is a different type, like 'image/jpeg'
        ),);
    }
    else
      {
        // add empty image field, since image is optional, but the field is mandatory
        // content type will still be image/png
        request.files.add(
          MultipartFile.fromBytes(
            'cover_image',
            Uint8List(0),
            filename: 'empty.jpg', // Placeholder file name
            contentType: MediaType('image', 'png'),
          ),
        );
      }

    // add headers
    request.headers.addAll(headers);
    StreamedResponse streamedResponse;
    try
    {
      streamedResponse = await request.send();
    }
    catch(e)
    {
      // failed to send
      throw CommunicationException();
    }

    if(streamedResponse.statusCode==401)
    {
      // token has expired
      throw AuthenticationException();
    }
    else if(streamedResponse.statusCode==404)
    {
      // book not found
      throw BookNotFoundException();
    }
    else if (streamedResponse.statusCode==403)
    {
      // forbidden
      throw ForbiddenException();
    }
    else if(streamedResponse.statusCode!=200)
    {
      // unknown exception at server
      throw Exception();
    }

    // get the response obj
    Response response = await Response.fromStream(streamedResponse);

    // get book
    Map<String, dynamic> bookJson = jsonDecode(response.body);

    return bookFromJson(bookJson);
  }

  // method to delete a book
  static Future<void> deleteBook({required int id, required String jwt}) async
  {
    final url = Uri.parse(Config.baseUrl+_deleteBookUrl+id.toString());

    Response response;

    try
    {
      response = await delete(
          url,
          headers: {
            "Authorization": "Bearer $jwt"
          }
      );
    }
    catch(e)
    {
      // failed to connect
      throw CommunicationException();
    }
    if(response.statusCode==401)
    {
      // token expired
      throw AuthenticationException();
    }
    else if(response.statusCode==404)
    {
      throw BookNotFoundException();
    }
    else if (response.statusCode==403)
    {
      // forbidden
      throw ForbiddenException();
    }
    else if(response.statusCode!=200)
    {
      throw Exception();
    }

  }

}