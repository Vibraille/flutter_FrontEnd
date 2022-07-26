import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/notesData.dart';
import 'package:rxdart/rxdart.dart';

class NoteBloc{
  final _client = NotesClient();
  final _notesController = StreamController<String>();
  Sink<String> get title => _notesController.sink;

  final _noteIdController = StreamController<int>();
  Sink<int> get noteId => _noteIdController.sink;

  late Stream<List<Note>?> allNotesStream;
  late Stream<Note?> noteDetailStream;
  late Stream<Note?> noteEditStream;
  late Stream<String?> noteDeleteStream;

  late String bearer;
  late SharedPreferences sp;

  NoteBloc() {
    getPreferences().whenComplete( () => {
      bearer = sp.getString("accessToken")!});

    allNotesStream = _notesController.stream.switchMap(
            (bearer) => _client.fetchAllNotes(bearer).asStream());


    noteDetailStream = _noteIdController.stream.switchMap(
            (noteId) => _client.fetchNoteDetails(noteId, bearer).asStream());

    noteEditStream = _noteIdController.stream.switchMap(
            (noteId) => _client.editNoteDetails(noteId, bearer, "").asStream());

    noteDeleteStream = _noteIdController.stream.switchMap(
            (noteId) => _client.deleteNote(noteId, bearer).asStream());
  }

  Future getPreferences() async{
    sp = await SharedPreferences.getInstance();
  }

  void dispose() {
    _notesController.close();
    _noteIdController.close();
  }
}