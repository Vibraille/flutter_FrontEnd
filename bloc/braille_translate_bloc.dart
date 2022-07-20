import 'dart:async';

import '../data/brailleData.dart';
import './bloc.dart';

class BrailleBloc implements Bloc {
  final _client = BrailleClient();
  final _brailleController = StreamController<String?>();
  Sink<String?> get braille => _brailleController.sink;
  late Stream<String?> translateStream;

  BrailleBloc() { /*
    translateStream = _brailleController.stream
        .startWith(null) // 1
        .debounceTime(const Duration(milliseconds: 100)) // 2
        .switchMap(
      // 3hg
          (query) => _client
          .fetchArticles(query)
          .asStream() // 4
          .startWith(null), // 5

    );*/
  }

  @override
  void dispose() {
    _brailleController.close();
  }
}