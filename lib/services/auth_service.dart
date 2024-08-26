import 'dart:convert';
import 'dart:io';

import 'package:booklisting_app_client/config.dart';
import 'package:http/http.dart';

import '../exceptions/exceptions.dart';

// auth related dealing with server go here

class AuthService
{

  static const String _signupUrl = "/create-account";
  static const String _loginUrl = "/token";

  // method to attempt signup
  static Future<void> attemptSignup(String email, String password, String fullName)
  async {

    Response response;
    try
    {
      // api call and get response
      response = await post(
          Uri.parse(Config.baseUrl + _signupUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
            'fullName': fullName
          })
      );
    }
    catch (e)
    {
      // failed to req and get resp
      // throw custom error
      throw CommunicationException();
    }

    if(response.statusCode==200)
    {
      // success
      return;
    }
    else if(response.statusCode==409)
    {
      // email taken
      throw ConflictException();
    }
    else
    {
      // unknown error at server
      throw Exception();
    }
  }

  // method to attempt login, will return a future, which resolves to jwt
  static Future<String> attemptLogin(String email, String password)
  async {
    StreamedResponse response;

    final url = Uri.parse(Config.baseUrl + _loginUrl);

    MultipartRequest request = MultipartRequest("POST", url);

    // add fields
    request.fields["username"] = email;
    request.fields["password"] = password;

    try
    {
      response = await request.send();
    }
    catch(e)
    {
      print(e);
      throw CommunicationException();
    }

    if(response.statusCode==200)
    {
      // success
      return await response.stream.bytesToString();
    }

    if(response.statusCode==401)
    {
      throw AuthenticationException();
    }
    else
    {
      throw Exception();
    }

  }
}