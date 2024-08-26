import 'package:booklisting_app_client/services/auth_service.dart';
import 'package:booklisting_app_client/shared/simple_dialog.dart';
import 'package:booklisting_app_client/shared/simple_loader.dart';
import 'package:flutter/material.dart';

import '../exceptions/exceptions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // the key for validating the form
  final _formKey = GlobalKey<FormState>();

  // controller for email field
  final emailController = TextEditingController();

  // controller for password
  final passwordController = TextEditingController();

  // state for if password is visible or not
  bool passwordVisible = false;

  // dispose both controllers on dispose
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: const Text("Authentication"),
        centerTitle: true,

      ),

      body: Form(

        // specifying key for validation
        key: _formKey,

        child: Column(
          children: [

            // fields go here

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

            // login button
            ElevatedButton(
              onPressed: () async {
                
                // validate
                if(_formKey.currentState!.validate())
                {
                  String jwt;
                  try
                  {
                    // show loader
                    showSimpleLoader(context: context);

                    try
                    {
                      // call the login handler
                      jwt = await AuthService.attemptLogin(emailController.text, passwordController.text);
                      // no error, save jwt
                      print(jwt);
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
                  }
                  on CommunicationException catch (e)
                  {
                    if(context.mounted)
                    {
                      // will show dialog that failed to communicate to server
                      showSimpleDialog(context: context, message: "Failed to connect to server. Please check your network connection and try again");
                    }
                  }
                  on AuthenticationException catch (e)
                  {
                    if(context.mounted)
                    {
                      showSimpleDialog(context: context, message: "Incorrect username or password.", title: "Failed to login");
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

              child: const Text("Login"),
            )

          ],
        ),

      ),

    );
  }
}
