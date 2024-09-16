import 'dart:io';

import 'package:booklisting_app_client/entities/Author.dart';
import 'package:booklisting_app_client/entities/Book.dart';
import 'package:booklisting_app_client/exceptions/exceptions.dart';
import 'package:booklisting_app_client/shared/simple_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/book/BookForm.dart';
import '../services/book_service.dart';
import '../shared/simple_loader.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key, required this.bookId, required this.jwt, required this.email});

  // book id of book to be displayed
  final int bookId;
  // jwt
  final String jwt;
  // email of user
  final String email;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {

  Book? book;

  bool isLoading = true;

  void fetchData() async
  {
    // show loading
    setState(() {
      isLoading = true;
    });
    // get book
    try
    {
      book = await BookService.getBookById(jwt: widget.jwt, id: widget.bookId);
      // set loading to false
      setState(() {
        isLoading = false;
      });
    }
    on CommunicationException catch(e)
    {
      // failed to communicate
      if(mounted)
      {
        showSimpleDialog(
            context: context,
            message: "Failed to communicate with server",
            // go back to home page on okay
            onOkay: ()
            {
              // pop twice, one for the dialog and one for the page
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
        );
      }
    }
    on AuthenticationException catch(e)
    {
      // token expired
      if(mounted)
      {
        showSimpleDialog(
            context: context,
            message: "Your session has expired. Please login again",
            // go back to login page on okay
            onOkay: ()
            {
              // pop twice, one for the dialog and one for the page
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
        );
      }
    }
    on BookNotFoundException catch(e)
    {
      // book not found
      if(mounted)
      {
        showSimpleDialog(
            context: context,
            message: "Book not found",
            // go back to home page on okay
            onOkay: ()
            {
              // pop twice, one for the dialog and one for the page
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
        );
      }
    }
    catch(e)
    {
      // unknown error
      if(mounted)
      {
        showSimpleDialog(
            context: context,
            message: "An unknown error occurred",
            // go back to home page on okay
            onOkay: ()
            {
              // pop twice, one for the dialog and one for the page
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
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
    return Scaffold(
      appBar: AppBar(
        title: (book!=null)?Text(book!.title):const Text("Book"),
      ),
      body: Center(

        child: isLoading?
        const CircularProgressIndicator()
        :
        Column(
          children: [

            // image of book
            Image.network(
              BookService.getCoverImageUrl(book!.coverImagePath),
              headers: {
                "Authorization": "Bearer ${widget.jwt}"
              },
              width: 100,
              height: 200,
            ),

            // title of book, in bigger font
            Text(
              book!.title,
              style: const TextStyle(
                fontSize: 20
              ),
            ),

            // author of book
            Text(
              book!.author.fullName,
              style: const TextStyle(
                fontSize: 15
              ),
            ),

            // leave a space
            const SizedBox(height: 10,),

            // "Buy Book" text, in black, bigger font
            const Text(
              "Buy Book",
              style: TextStyle(
                fontSize: 20
              ),
            ),

            // leave a space
            const SizedBox(height: 10,),

            // links to buy book
            Column(
              children: book!.bookLinks.map(
                (link)=>
                InkWell(
                  child: Text(
                    link.name,
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.blue
                    ),
                  ),
                  onTap: ()
                  {
                    // open the link
                    launchUrlString(link.link);
                  },
                )
              ).toList(),
            ),

            // leave a space
            const SizedBox(height: 10,),

            // button to edit, in case user is author
            if(book!.author.email == widget.email)
              ElevatedButton(
                onPressed: ()
                {
                  // show update form
                  _showUpdateBookForm();
                },
                child: const Text("Edit"),
              ),

            // button to delete, in case user is author
            if(book!.author.email == widget.email)
              ElevatedButton(
                onPressed: ()
                {
                  // show dialog to confirm delete
                  showSimpleDialog(
                    title: "Delete Book",
                    context: context,
                    message: "Are you sure you want to delete this book?",
                    onOkay: ()
                    async {
                      // show loader
                      showSimpleLoader(context: context);

                      try
                      {
                        try
                        {
                          // call delete book
                          await BookService.deleteBook(jwt: widget.jwt, id: widget.bookId);
                        }
                        catch(e)
                        {
                          rethrow;
                        }
                        finally
                        {
                          // hide loader
                          if(context.mounted)
                          {
                            hideSimpleLoader(context: context);
                          }
                        }

                        if(context.mounted)
                        {
                          // success
                          // pop the confirmation dialog
                          Navigator.of(context).pop();
                          // pop the page
                          Navigator.of(context).pop();
                        }
                      }
                      on CommunicationException catch(e)
                      {
                        if(context.mounted)
                        {
                          showSimpleDialog(
                            context: context,
                            message: "Failed to connect to server. Please check your connection",
                          );
                        }
                      }
                      on AuthenticationException catch(e)
                      {
                        if(context.mounted)
                        {
                          showSimpleDialog(
                            context: context,
                            message: "Your session is expired. Please login again",
                          );
                        }
                      }
                      on BookNotFoundException catch(e)
                      {
                        if(context.mounted)
                        {
                          showSimpleDialog(
                            context: context,
                            message: "Book not found",
                          );
                        }
                      }
                      on ForbiddenException catch(e)
                      {
                        if(context.mounted)
                        {
                          showSimpleDialog(
                            context: context,
                            message: "You are not allowed to delete this book",
                          );
                        }
                      }
                      on Exception catch (e)
                      {
                        if(context.mounted)
                        {
                          showSimpleDialog(
                            context: context,
                            message: "Unknown error occurred. Please try again later",
                          );
                        }
                      }
                    });
                    },
                    child: const Text("Delete"),
                  )

          ],
        )

      ),
    );
  }

  // to show dialog for updating a book
  void _showUpdateBookForm()
  {
    showDialog(
        context: context,
        builder: (BuildContext ctx)
        {
          return AlertDialog(

              title: const Text("Add Book"),

              content: SizedBox(

                height: 500,

                child: BookForm(

                  // form is in edit mode
                  editMode: true,

                  // book to edit
                    book: book!,

                  // handler to call when adding
                    addCallback: ({required Book book, File? coverImage})
                    async {
                      // show loading spinner
                      showSimpleLoader(context: context);

                      // create a new book
                      Book bookNew = Book(
                          title: book.title,
                          id: widget.bookId,
                          author: const Author(id: 0, email: "", fullName: ""),
                          bookLinks: book.bookLinks,
                          coverImagePath: ""
                      );

                      // send request
                      try
                      {
                        try
                        {
                          await BookService.updateBook(book: bookNew, coverImage: coverImage, jwt: widget.jwt);
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
                      on BookNotFoundException catch(e)
                      {
                        if(mounted)
                        {
                          showSimpleDialog(
                            context: context,
                            message: "Book not found",
                          );
                        }
                      }
                      on ForbiddenException catch(e)
                      {
                        if(mounted)
                        {
                          showSimpleDialog(
                            context: context,
                            message: "You are not allowed to update this book",
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
