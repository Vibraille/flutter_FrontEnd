import 'dart:async';

import '../data/notesData.dart';
import './bloc.dart';
//import 'package:article_finder/data/article.dart';
//import 'package:rxdart/rxdart.dart';

class NoteListBloc implements Bloc {
  final _client = NotesClient();
  final _searchQueryController = StreamController<String?>();
  Sink<String?> get searchQuery => _searchQueryController.sink;
  late Stream<List<Note>?> noteStream;
/*
  NoteListBloc() {
    noteStream = _searchQueryController.stream
        .startWith(null) // 1
        .debounceTime(const Duration(milliseconds: 100)) // 2
        .switchMap(
      // 3
          (query) => _client
          .fetchArticles(query)
          .asStream() // 4
          .startWith(null), // 5
    );
  }
 */
  @override
  void dispose() {
    _searchQueryController.close();
  }
}