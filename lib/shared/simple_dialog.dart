import 'package:flutter/material.dart';

// a function to show a simple dialog with the given message and using the give context

void showSimpleDialog({required BuildContext context, String title="An Error Occurred", required String message, VoidCallback? onOkay})
{
  showDialog(
    context: context,
    builder: (BuildContext ctx){
      return AlertDialog(
        title: Text(title),
        content: Text(message),

        actions: [

          // ok button
          TextButton(
            onPressed: onOkay ?? (){
              // close the dialog
              Navigator.of(context).pop();
            },
            child: const Text(
              "Okay",
              textAlign: TextAlign.end,
            ),
          )
        ],

      );
    }
  );
}