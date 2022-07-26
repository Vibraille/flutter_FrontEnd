import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NotesClient {
  final _noteUrl = "http://ec2-3-142-74-196.us-east-2.compute.amazonaws.com:8000/notes/";
  // /notes. Get all notes associated with user
  //   /notes/id/ details of selected notes
  // /notes/id/edit
  // /notes/id/delete note


  Future<List<Note>?> fetchAllNotes(String bearer) async {
    final response = await http.get(
        Uri.parse(_noteUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer $bearer",
        }
    );
    // Status code for no text detected
    if (response.statusCode == 200) {
      List<Map<String, dynamic> > notesList = List.from(jsonDecode(response.body));
      List<Note> notes = <Note>[];
      for (int i = 0; i < notesList.length; i++) {
        Map<String, dynamic>  noteJson = notesList[i];
        Note nextNote = Note.fromJson(noteJson["fields"], noteJson["pk"]);
        notes.add(nextNote);
      }
      return notes;

    } else if (response.statusCode == 404) {
      return null; // No notes available
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to retrieve all notes.');
    }
  }

  Future<Note?> editNoteDetails(int id , String bearer, String title) async {
    final response = await http.put(
      Uri.parse("$_noteUrl$id/edit"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer $bearer",
      },
      body: jsonEncode(<String, String>{
        "title": title,
       // "contents": contents
      }),

    );
    // Status code for no text detected
    if (response.statusCode == 200) {
      Map<String, dynamic> noteJson = List.from(jsonDecode(response.body))[0];
      return Note.fromJson(noteJson["fields"], noteJson["pk"]);
    } else if ((response.statusCode == 401)) {
      // unathorized
      return null;

    } else if ((response.statusCode == 404)) {
      // failed to retrieve
      return null;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to retrieve node details.');
    }
  }


  Future<Note?> fetchNoteDetails(int id , String bearer) async {
    final response = await http.get(
        Uri.parse("$_noteUrl$id/"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer $bearer",
        }
    );
    // Status code for no text detected
    if (response.statusCode == 200) {
      Map<String, dynamic> noteJson = List.from(jsonDecode(response.body))[0];
      return Note.fromJson(noteJson["fields"], noteJson["pk"]);
    } else if  (response.statusCode == 404) {
      return null; // no note found
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to retrieve node details.');
    }
  }

  Future<String> deleteNote(int id, String bearer) async {
    final response = await http.delete(
        Uri.parse("$_noteUrl$id/delete"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer $bearer",
        }
    );
    // Status code for no text detected
    if (response.statusCode == 200) {
      return "Note deleted successfully";
    } else if (response.statusCode == 401) {
      // not authorized
      return "Note failed to delete, try again";
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to delete Note.');
    }
  }
}

class Note {
  final String date;
  final String ascii;
  final String braille;
  final String title;
  final int noteId;
  final String binary;

  const Note({required this.date, required this.ascii, required this.braille,
              required this.title, required this.noteId, required this.binary});

  factory Note.fromJson(Map<String, dynamic> json, int id) {
    return Note(
        date: json["created"],
        ascii: json["ascii_text"],
        braille: json["braille_format"],
        title: json["title"],
        noteId: id,
        binary: json["braille_binary"]
    );
  }
}

