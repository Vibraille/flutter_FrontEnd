import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthClient {
  final _hostUrl = "http://ec2-3-142-74-196.us-east-2.compute.amazonaws.com:8000";

  Future<RegisterAccount?> registerUser(String username, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse("$_hostUrl/register/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email' : email,
        'phone_number' : phone,
        'password' : password
      }),
    );
    // Status code for no text detected
    if (response.statusCode == 201) {
      return RegisterAccount.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      return null;
    } else {
      throw Exception('Failed to register user.');
    }

  }

  Future<String?> verifyNumber(String phone, String code) async {
    final response = await http.put(
      Uri.parse("$_hostUrl/verify/phone/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "phone_number": phone,
        "verify_str": code
      }),
    );
    if (response.statusCode == 200) {
      return "Your phone number has been verified!";
    } else if ((response.statusCode == 400)) {
      return "Failed to verify your number. Please try again";
    } else {
      throw Exception('Failed to verify number.');
    }
  }

  Future<String?> verifyEmail(String email, String code) async {
    final response = await http.put(
      Uri.parse("$_hostUrl/verify/email/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": email,
        "verify_str": code
      }),
    );
    if (response.statusCode == 200) {
      return "Your email has been verified!";
    } else if ((response.statusCode == 400)) {
      return "Failed to verify your email. Please try again";
    } else {
      throw Exception('Failed to verify email.');
    }
  }

  Future<String?> freshVerifyCode(String email) async {
    final response = await http.put(
      Uri.parse("$_hostUrl/verify/email/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "email": email
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["verification_email"];
    } else if ((response.statusCode == 400)) {
      return "Request Failed";
    } else {
      throw Exception('Failed to retrieve verification code.');
    }
  }

  Future<Account?> loginUser(Map<String, String> loginCreds) async {
    final response = await http.post(
      Uri.parse("$_hostUrl/login/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loginCreds),
    );
    // Status code for no text detected
    if (response.statusCode == 200) {
      return Account.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400 || response.statusCode == 500) {
      return null;
    } else {
      throw Exception('Failed to Login.');
    }
  }

  Future<String?> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse("$_hostUrl/login/refresh/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "refresh" : refreshToken
      }),
    );
    // Status code for no text detected
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400 || response.statusCode == 500) {
      return "Failed to refresh token";
    } else {
      throw Exception('Failed to Login.');
    }
  }

}

class RegisterAccount  {
  final String username;
  final String email;
  final String emailVerifyCode;
  final String phoneVerifyCode;

  const RegisterAccount({required this.username, required this.email,
                  required this.emailVerifyCode, required this.phoneVerifyCode});

  factory RegisterAccount.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> verify =  json["verification_strings"];
    return RegisterAccount(
        username: json["username"],
        email: json["email"],
        emailVerifyCode: verify["verify_email"],
        phoneVerifyCode: verify["verify_phone"]
    );
  }
}

class Account  {
  final String username;
  final String phone;
  final String email;
  final String refreshToken;
  final String accessToken;
  final String emailCode;

  const Account({required this.username, required this.email,required this.emailCode,
    required this.phone, required this.refreshToken, required this.accessToken});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        username: json["username"],
        email: json["email"],
        phone: json["phone_number"],
        refreshToken: json["refresh"],
        accessToken: json["access"],
        emailCode: json["user"]["verify_email"]
    );
  }
}

