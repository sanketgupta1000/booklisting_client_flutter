import 'dart:convert';

import 'package:booklisting_app_client/pages/AuthPage.dart';
import 'package:booklisting_app_client/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String? jwt;
  bool isJwtExpired = true;

  void extractJwt () async
  {
    const storage = FlutterSecureStorage();

    String? jsonWt = await storage.read(key: "jwt");

    bool isExpired = true;

    // check expiry
    if(jsonWt!=null)
    {

      // jwt as array of its parts
      final jwtArr = jsonWt.split(".");

      final payload = json.decode(ascii.decode(base64.decode(base64.normalize(jwtArr[1]))));

      isExpired = !DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000).isAfter(DateTime.now());
    }

    setState((){
      jwt = jsonWt ?? "";
      isJwtExpired = isExpired;
    });
  }

  @override
  void initState() {
    super.initState();
    extractJwt();
  }

  @override
  Widget build(BuildContext context) {

    if(jwt==null)
      {
        // jwt is not yet read from fss
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    else if((jwt=="") || (isJwtExpired))
      {
        // show auth page
        return const AuthPage();
      }
    else
      {
        return const HomePage();
      }

  }
}
