import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class BrailleClient {
  final _host = '/login/';

// Change password
  // login
  // registration
  Future<Account> fetchAccount(String imagePath, String bearer) async {
    final response = await http.post(
      Uri.parse(_host),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearer,
      },
      body: jsonEncode(<String, String>{
        'img': imagePath,
      }),
    );
    // Status code for no text detected
    if (response.statusCode == 204) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return Account.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400){

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to retrieve translation.');
    }

  }

}

class Account  {
  final String name;
  final String email;
  final String phone;
  final int verified; 

  const Account({required this.name, required this.email, required this.phone});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        name: json["created"],
        email: json["ascii_text"],
        phone: json["braille_format"]
    );
  }
}

