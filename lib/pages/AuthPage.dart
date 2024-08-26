import 'package:booklisting_app_client/shared/simple_dialog.dart';
import 'package:flutter/material.dart';

import 'package:booklisting_app_client/components/auth/login_form.dart';
import 'package:booklisting_app_client/components/auth/signup_form.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'HomePage.dart';

// will have tabs for login and signup

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {

  // controller for tabs, to bind tabs with views
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: const Text("Authentication"),
          centerTitle: true,
          // specifying tabs
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: "Login"),
              Tab(text: "Signup")
            ],
          ),
        ),

        // specifying content for tabs
        body: TabBarView(
          controller: tabController,
          children: [

            // order is important here
            LoginForm(

              onSuccess: ({required String jwt})
              {
                // flutter secure storage
                const storage = FlutterSecureStorage();

                // save jwt
                storage.write(key: "jwt", value: jwt);

                // redirect to home
                Navigator.pushReplacement(
                    context, MaterialPageRoute(
                    builder: (BuildContext context){
                      return const HomePage();
                    }
                  )
                );

              }

            ),
            SignupForm(
              onSuccess: ()
                {
                  // show dialog
                  showSimpleDialog(context: context, message: "Successfully created account. Please login.", title: "Success");
                  // switch to login tab
                  tabController.index = 0;
                }
            )

          ],
        ),
    );
  }
}
