import 'package:flutter/material.dart';

// will create two functions: one to show loader and one to hide it.

void showSimpleLoader({required BuildContext context, String text="Loading..."})
{
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx){
      return AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            Container(margin: const EdgeInsets.only(left: 5),child:Text(text)),
          ]
        ),
      );
    }
  );
}

void hideSimpleLoader({required BuildContext context})
{
  // pop
  Navigator.of(context).pop();
}