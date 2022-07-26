import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'notesData.dart';

class BrailleClient {
  final _host = 'http://ec2-3-142-74-196.us-east-2.compute.amazonaws.com:8000/notes/translate/';


  Future<Note?> fetchTranslation(String imagePath, String bearer) async {
    final response = await http.post(
      Uri.parse(_host),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer $bearer",
      },
      body: jsonEncode(<String, String>{
        'img': imagePath,
      }),
    );
    // Status code for no text detected
    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      Map<String, dynamic>  noteJson = jsonDecode(response.body);
      return Note.fromJson(noteJson, noteJson["id"]);
    } else if (response.statusCode == 500) {
        developer.log("error1", name: "json", error:jsonDecode(response.body));

      return null; // if null pop up alert no text detected
    } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to retrieve translation.');
    }

  }

}
