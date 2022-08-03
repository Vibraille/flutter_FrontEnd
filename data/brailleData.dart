import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'notesData.dart';

class BrailleClient {
  final _host = 'http://ec2-3-142-74-196.us-east-2.compute.amazonaws.com:8000/notes/translate/';
  Future<Note?> fetchTranslation(String imagePath, String bearer) async {
    final request = http.MultipartRequest('POST', Uri.parse(_host));
    request.headers.addAll(<String, String>{
    'Authorization': "Bearer $bearer",
      'Content-Type': "multipart/form-data",
    });
    final path = await http.MultipartFile.fromPath('img', imagePath,
        contentType: MediaType('image', 'jpg'), filename: "note.jpg");

    request.files.add(path);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    log(jsonDecode(response.body).toString());
    // // Status code for no text detected
    if (response.statusCode == 201) {

      Map<String, dynamic>  noteJson = jsonDecode(response.body);
      return Note.fromJson(noteJson, noteJson["id"]);
    } else
      if (response.statusCode == 500) {
       log(jsonDecode(response.body));
      return null; // if null pop up alert no text detected
    } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to retrieve translation.');
    }

  }

}
