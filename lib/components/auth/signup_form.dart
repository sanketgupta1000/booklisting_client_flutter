import 'package:booklisting_app_client/services/auth_service.dart';
import 'package:booklisting_app_client/shared/simple_dialog.dart';
import 'package:booklisting_app_client/shared/simple_loader.dart';
import 'package:flutter/material.dart';

import 'package:booklisting_app_client/exceptions/exceptions.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {

  // the key for validating the form
  final _formKey = GlobalKey<FormState>();

  // controller for full name field
  final fullNameController = TextEditingController();

  // controller for email field
  final emailController = TextEditingController();

  // controller for password
  final passwordController = TextEditingController();

  // state for if password is visible or not
  bool passwordVisible = false;

  // dispose all controllers on dispose
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(

      // specifying key for validation
      key: _formKey,

      child: Column(
        children: [

          // fields go here

          TextFormField(
            decoration: const InputDecoration(labelText: "Full Name"),

            validator: (value)
            {
              if(value==null || value.isEmpty)
              {
                return "Please enter your full name";
              }
              return null;
            },

            // let's supply the controller
            controller: fullNameController,
          ),

          TextFormField(
            decoration: const InputDecoration(labelText: "Email"),

            validator: (value)
            {
              if(value==null || value.isEmpty)
              {
                return "Please enter email";
              }
              return null;
            },

            // let's supply the controller
            controller: emailController,
          ),

          // field for password
          TextFormField(

            // is the text hidden?
            obscureText: !passwordVisible,

            decoration: InputDecoration(

                labelText: "Password",

                suffixIcon: IconButton(

                  // on press, toggle the passwordVisible
                  onPressed: (){
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },

                  // icons to display beside the field
                  icon: passwordVisible?const Icon(Icons.visibility_off):const Icon(Icons.visibility),

                )

            ),

            validator: (value)
            {
              if(value==null || value.isEmpty)
              {
                return "Please enter password";
              }
              return null;
            },

            // let's supply the controller
            controller: passwordController,
          ),

          // signup button
          ElevatedButton(
            onPressed: () async {

              // validate
              if(_formKey.currentState!.validate())
              {
                try
                {
                  // show loader
                  showSimpleLoader(context: context);

                  try
                  {
                    // call the signup handler
                    await AuthService.attemptSignup(emailController.text, passwordController.text, fullNameController.text);
                  }
                  catch(e)
                  {
                    // rethrow
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

                  // no error, redirect to login
                  widget.onSuccess();
                }
                on CommunicationException catch (e)
                {
                  if(context.mounted)
                  {
                    // will show dialog that failed to communicate to server
                    showSimpleDialog(context: context, message: "Failed to connect to server. Please check your network connection and try again");
                  }
                }
                on ConflictException catch (e)
                {
                  if(context.mounted)
                  {
                    showSimpleDialog(context: context, message: "Email is already taken.", title: "Failed to signup");
                  }
                }
                catch(e)
                {
                  if(context.mounted)
                  {
                    showSimpleDialog(context: context, message: "An unknown error occurred");
                  }
                }

              }

            },

            child: const Text("Signup"),
          )

        ],
      ),

    );
  }
}
