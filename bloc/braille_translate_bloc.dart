import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/brailleData.dart';
import '../data/notesData.dart';

import 'package:rxdart/rxdart.dart';

class BrailleBloc {
  final _client = BrailleClient();
  final _brailleController = StreamController<String>();
  Sink<String> get imagePath => _brailleController.sink;
  late Stream<Note?> translateStream;
  late String bearer;
  late SharedPreferences sp;

  BrailleBloc() {
    getPreferences().whenComplete( () => {
      bearer = sp.getString("accessToken")!});

      translateStream = _brailleController.stream.switchMap(
          (imagePath) => _client.fetchTranslation(imagePath, bearer).asStream());
  }

  Future getPreferences() async{
    sp = await SharedPreferences.getInstance();
  }

  void dispose() {
    _brailleController.close();

  }
}