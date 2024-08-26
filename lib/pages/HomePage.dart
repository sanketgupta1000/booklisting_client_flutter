import 'dart:io';

import 'package:booklisting_app_client/components/book/BookCard.dart';
import 'package:booklisting_app_client/exceptions/exceptions.dart';
import 'package:booklisting_app_client/pages/AuthPage.dart';
import 'package:booklisting_app_client/services/book_service.dart';
import 'package:booklisting_app_client/shared/simple_dialog.dart';
import 'package:booklisting_app_client/shared/simple_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../components/book/AddBookForm.dart';
import '../entities/Book.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? jwt;

  // the list of books
  List<Book> books = [];

  // is the home page loading
  bool isLoading = true;

  void fetchData () async
  {
    // show loading
    setState(() {
      isLoading = true;
    });
    // get jwt
    const storage = FlutterSecureStorage();
    String? jsonWt = await storage.read(key: "jwt");
    List<Book> fetchedBooks;
    // get books
    try
    {
      try
      {
        fetchedBooks = await BookService.getAllBooks(jwt: jsonWt!);
      }
      catch(e)
      {
        rethrow;
      }
      finally
      {
        // set loading to false
        setState(() {
          isLoading = false;
        });
      }

      // set the state
      setState(() {
        jwt = jsonWt;
        books = fetchedBooks;
      });

    }
    on CommunicationException catch(e)
    {
      // failed to communicate
      if(mounted)
      {
        showSimpleDialog(
            context: context,
            message: "Failed to connect to server. Please check your connection",
            onOkay: ()
            {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
        );
      }
    }
    on AuthenticationException catch(e)
    {
      // token expired
      // redirect to authpage
      if(mounted)
      {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext ctx)=>const AuthPage()
            )
        );
      }
    }

  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {

    print("build called");
    // print books for now
    // print(books);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Home"),
      ),

      body: isLoading?
      const Center(

        child:CircularProgressIndicator(),


      )
      :
      SingleChildScrollView(
        child: Column(
          children: books.map(
              (book)=>BookCard(book: book, onTap:(){}, jwt: jwt!)
          ).toList(),
        ),
      ),

      floatingActionButton: isLoading?null:

          FloatingActionButton(

            onPressed: ()
            {
              _showAddBookForm();
            },

            child: const Icon(Icons.add),

          )
      ,

    );
  }

  // to show dialog for adding a book
  void _showAddBookForm()
  {
    showDialog(
      context: context,
      builder: (BuildContext ctx)
      {
        return AlertDialog(

          title: const Text("Add Book"),

          content: SizedBox(

            height: 500,

            child: AddBookForm(

              // handler to call when adding
              addCallback: ({required Book book, required File coverImage})
              async {
                // show loading spinner
                showSimpleLoader(context: context);

                // send request
                try
                {
                  try
                  {
                    await BookService.addBook(book: book, coverImage: coverImage, jwt: jwt!);
                  }
                  catch(e)
                  {
                    rethrow;
                  }
                  finally
                  {
                    if(mounted)
                    {
                      // hide loader
                      hideSimpleLoader(context: context);
                    }
                  }

                  if(mounted)
                  {
                    // success
                    // pop the form
                    Navigator.of(context).pop();
                    // fetch the data again
                    fetchData();
                  }

                }
                on CommunicationException catch(e)
                {
                  if(mounted)
                  {
                    showSimpleDialog(
                      context: context,
                      message: "Failed to connect to server. Please check your connection",
                    );
                  }
                }
                on AuthenticationException catch(e)
                {
                  if(mounted)
                  {
                    showSimpleDialog(
                      context: context,
                      message: "Your session is expired. Please login again",
                    );
                  }
                }
                on Exception catch (e)
                {
                  if(mounted)
                  {
                    showSimpleDialog(
                      context: context,
                      message: "Unknown error occurred. Please try again later",
                    );
                  }
                }

              },

              cancelCallback:()
              {
                // close the form
                Navigator.of(context).pop();
              }
            ),

          )

        );
      }
    );
  }

}
