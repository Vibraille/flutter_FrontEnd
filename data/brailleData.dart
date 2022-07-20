import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class BrailleClient {
  final _host = '/notes/translate/';

  /*
  curl -X POST -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU4MjA1ODA2LCJpYXQiOjE2NTgyMDU1MDYsImp0aSI6IjdmNTk4Y2RlYmZhYzQwZTc4YWQwOGMzODNlZmNkZjhkIiwidXNlcl9pZCI6MiwidXNlcm5hbWUiOiJ0ZXN0X3VzZXIifQ.T1Qr5WAhAHrwf7UYEXAalMTpCixpN_Qj52ZwB_LHBc0"
   -F "img=@/Users/ricktesmond/Desktop/Street-Signs.jpg" http://localhost:8000/notes/translate/
  */
  Future<Translation> fetchTranslation(String imagePath, String bearer) async {
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
      return Translation.fromJson(jsonDecode(response.body));
    } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to retrieve translation.');
    }

  }

}
class Translation {
  final String date;
  final String ascii;
  final String braille;
  final String title;

  const Translation({required this.date, required this.ascii, required this.braille, required this.title});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      date: json["created"],
      ascii: json["ascii_text"],
      braille: json["braille_format"],
      title: json["title"]
    );
  }
 }