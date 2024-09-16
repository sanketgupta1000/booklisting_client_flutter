import 'dart:io';

import 'package:booklisting_app_client/entities/Author.dart';
import 'package:booklisting_app_client/entities/BookLink.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../entities/Book.dart';

class LinkController
{
  LinkController():
        linkNameController = TextEditingController(),
        linkValueController = TextEditingController();

  final TextEditingController linkNameController;
  final TextEditingController linkValueController;
}

class BookForm extends StatefulWidget {
  const BookForm({
    super.key,
    required this.addCallback,
    required this.cancelCallback,
    // is the form for editing a book
    this.editMode = false,
    // the data to be displayed in form
    this.book = const Book(id: 0, title: '', author: Author(id: 0, email: "", fullName: ""), bookLinks: [], coverImagePath: '', )

  });

  final Future<void> Function({required Book book, File? coverImage}) addCallback;
  final VoidCallback cancelCallback;

  final bool editMode;

  final Book book;

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {

  // key of form
  final _formKey = GlobalKey<FormState>();

  // controller for title
  final titleController = TextEditingController();

  // controller for selecting coverimage
  final coverImgController = TextEditingController();

  // selected image
  File? coverImage;

  // list of controllers for link
  List<LinkController> linkControllers = [];

  // initialize state
  @override
  void initState() {
    super.initState();
    titleController.text = widget.book.title;
    for(BookLink bl in widget.book.bookLinks)
      {
        // create a new link controller
        LinkController lc = LinkController();
        lc.linkNameController.text = bl.name;
        String linkText = bl.link;
        if(linkText.startsWith("https://"))
        {
          linkText = linkText.substring(8);
        }
        lc.linkValueController.text = linkText;
        linkControllers.add(lc);
      }
  }

  @override
  void dispose() {
    titleController.dispose();
    coverImgController.dispose();
    for (var lc in linkControllers) {
      lc.linkValueController.dispose();
      lc.linkNameController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(

      key: _formKey,

      child: Column(

        children: <Widget>[

          // field for title
          TextFormField(

            // label
            decoration: const InputDecoration(labelText: "Title"),

            validator: (value)
            {
              if(value==null || value.isEmpty)
              {
                return "Please enter book title";
              }
              return null;
            },

            // let's supply the controller
            controller: titleController,
          ),

          // field for choosing image
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
                labelText: "Cover Image",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.attach_file),

                  onPressed: () async
                  {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                        allowedExtensions: ["jpg", "png", "jpeg", "bmp"],
                        type: FileType.custom
                    );

                    if(result!=null)
                    {
                      // file selected
                      // save in state
                      setState(() {
                        coverImage = File(result.files.single.path!);
                      });
                    }

                  },

                )
            ),

            validator: (value)
            {
              if((!widget.editMode) && (coverImage==null))
              {
                return "Please select a file";
              }
              return null;
            },

          ),

          // display image if selected
          SizedBox(
            child: coverImage==null ? const Text("Image preview will be shown here") : Image.file(coverImage!, width: 100, height: 200),
          ),

          // displaying the fields for links
          Column(
            children: linkControllers.map((lc){
              return Row(

                children: [

                  SizedBox(
                    width: 75,
                    child: TextFormField(

                      // label
                      decoration: const InputDecoration(labelText: "Link Name"),

                      validator: (value)
                      {
                        if(value==null || value.isEmpty)
                        {
                          return "Please enter link name";
                        }
                        return null;
                      },

                      // let's supply the controller
                      controller: lc.linkNameController,
                    ),
                  ),

                  SizedBox(
                    width: 75,
                    child: TextFormField(

                      // label
                      decoration: const InputDecoration(
                          labelText: "Link",
                          prefixText: "https://"
                      ),

                      validator: (value)
                      {
                        if(value==null || value.isEmpty)
                        {
                          return "Please enter link";
                        }
                        return null;
                      },

                      // let's supply the controller
                      controller: lc.linkValueController,
                    ),
                  ),

                  // button to remove link
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: ()
                    {
                      setState(() {
                        linkControllers.remove(lc);
                      });
                    },
                  )

                ],

              );
            }).toList(),

          ),

          // button to add a link
          TextButton(
            child: const Text("Add Link"),

            onPressed: ()
            {
              setState(() {
                linkControllers.add(LinkController());
              });
            },

          ),

          // form handling buttons
          Row(

            children: [

              // submit button
              TextButton(
                onPressed: ()
                {
                  // validate:
                  if(_formKey.currentState!.validate())
                  {

                    // create book instance
                    List<BookLink> links = [];
                    for(var lc in linkControllers)
                    {
                      links.add(BookLink(id: 0, name: lc.linkNameController.text, link: "https://${lc.linkValueController.text}"));
                    }
                    Book book = Book(
                        id: 0,
                        title: titleController.text,
                        author: const Author(id: 0, email: "", fullName: ""),
                        bookLinks: links,
                        coverImagePath: ""
                    );

                    // valid, call the handler
                    widget.addCallback(book: book, coverImage: coverImage);
                  }
                },

                child: const Text("Submit"),
              ),

              // cancel button
              TextButton(onPressed: ()=>widget.cancelCallback(), child: const Text("Cancel"))

            ],

          )

        ],

      ),

    );
  }
}
