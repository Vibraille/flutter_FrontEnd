

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bloc/braille_translate_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../data/notesData.dart';

class DisplayBrailleScreen extends StatefulWidget {
  final String imagePath;
  const DisplayBrailleScreen({super.key, required this.imagePath});

  @override
  State<DisplayBrailleScreen> createState() => _DisplayBrailleScreenState();
}

//Image.file(File(widget.imagePath))
class _DisplayBrailleScreenState extends State<DisplayBrailleScreen> {
  //int _numOfBrailleCells = 4;
  late int noteId;


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Braille Page'),
        actions: [popUp(context)], backgroundColor: Colors.lightBlue,),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body:
    Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height *.12),
      child: _buildResult()

    ),//,

    );
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }


  TextButton popUp(BuildContext context) {
    return TextButton(
      onPressed: () =>
          showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  //title: const Text('Save Note?'),
                  content: const Text('Save to notes?',
                      semanticsLabel: "Would you like to save to notes?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Edit'), // pop context
                      child: const Text('Edit', semanticsLabel: "Edit Note",),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Save'), // pop context
                      child: const Text(
                        'Save', semanticsLabel: "Save to notes ",),
                    ),
                    TextButton(
                      onPressed: () => {
                        deleteNote(),
                        Navigator.of(context).pop(),

                        },
                      child: const Text('Cancel', semanticsLabel: "Cancel",),
                    ),
                  ],
                ),
          ),
      child: const Text('Done', semanticsLabel: "Done",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
    );
  }


  Widget _buildResult() {
    final bloc = BrailleBloc();
    bloc.imagePath.add(widget.imagePath);
    return StreamBuilder<Note?>(
      stream: bloc.translateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: AlertDialog(
          title: const Text('No text detected', semanticsLabel: "No text detected in image",
            style: TextStyle(fontSize: 30),),
          content: const Text('There was no text detected! \nPlease try again',
              semanticsLabel: "There was no text detected! Please try again",
          style: TextStyle(fontSize: 25),),
          actions: <Widget>[
            TextButton(
              onPressed: () =>  { Navigator.pop(context, 'Cancel')
              },
              child: const Text('Try again', semanticsLabel: "Try again", style: TextStyle(fontSize: 25),),
            )]
          ));
        }
        noteId = snapshot.data!.noteId;
        return ListView(
                    scrollDirection: Axis.horizontal,
                     shrinkWrap: true,
                    children: BrailleTranslation(snapshot.data!.binary).getBrailleTranslation(), // num of braillecells here
                );
      },
    );

  }

   Widget deleteNote() {
      final bloc = NoteBloc();
      bloc.noteId.add(noteId);
      return StreamBuilder<String?>(
          stream: bloc.noteDeleteStream,
          builder: (context, snapshot) {
          return const Center(child: CircularProgressIndicator());
     });
  }
}
class BrailleTranslation {
  List<BrailleCell> brailleCellList = <BrailleCell>[];
  List<Container> brailleTranslation = <Container>[];

  BrailleTranslation(String binaryBraille) {
    buildTranslation(binaryBraille);
  }

  buildTranslation(String binaryBraille) {
    //slice every 6 positions,
    int numOfCells = binaryBraille.length ~/ 6;
    int start = 0;
    int end = 6;
    for (int cellNum = 0; cellNum < numOfCells; cellNum++) {
      String binaryCell;
      bool isFirstCell = cellNum == 0 ? true : false;
      bool isLastCell;
      if (cellNum == numOfCells - 1) {
        isLastCell = true;
        binaryCell = binaryBraille.substring(start);
      } else {
        isLastCell = false;
        binaryCell = binaryBraille.substring(start, end);
      }
      brailleCellList.add(BrailleCell(isFirstCell, isLastCell, binaryCell));
      start += 6;
      end += 6;
    }
    int len = brailleCellList.length;
    for (int i = 0; i < len; i++) {
      BrailleCell curCell = brailleCellList[i];
      if (i < len - 1) curCell.setNextCell(brailleCellList[i + 1]);
      brailleTranslation.add(
          Container(width: 160,
              margin: const EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.center,
              child: curCell.getBrailleCell())
      );
      //set next node and add to  braille cell translation
    }
  }

  List<Container> getBrailleTranslation() {
    return brailleTranslation;
  }

}

class BrailleCell {
  bool enabled = false;
  late bool isSpace;
  late bool _lastCell;
  late BrailleCell next;
  List<bool> _read = <bool>[false, false, false, false, false, false];
  late GridView _brailleCell;


  BrailleCell(bool isFirstCell, bool isLastCell, String binaryBraille) {
    enabled = isFirstCell;
    _lastCell = isLastCell;
    isSpace = !binaryBraille.contains("1");
    _brailleCell = buildBrailleCell(binaryBraille);
  }

  GridView buildBrailleCell(String binaryBraille) {
    List<FloatingActionButton> brailleCells = <FloatingActionButton>[];
    List<int> positions = [0, 3, 1, 4, 2, 5]; //110000
    for (int i = 0; i < binaryBraille.length; i++) {
      if (binaryBraille[positions[i]] == "0") {
        _read[positions[i]] = true;
        brailleCells.add(
            const FloatingActionButton(
              backgroundColor: Colors.white38,
              enableFeedback: false,
              mini: true,
              onPressed: null,
            ));
      } else if (binaryBraille[positions[i]] == "1"){
        brailleCells.add(
            FloatingActionButton(
              enableFeedback: enabled,
              mini: true,
              onPressed: () {
                if (enabled) {
                    HapticFeedback.vibrate();
                    _read[positions[i]] = true;
                    if (isAllRead()) {
                      if (!_lastCell) {
                        //call next set of cells and set state
                        next.enabled = true;
                        if (next.isSpace) { // if there is a space assume more chars
                          next.next.enabled = true;
                        }
                      }
                    }
                  }
              }
            ));
      }
    }
    return GridView.count(
        padding: const EdgeInsets.only(left: 3, right: 3),
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
        crossAxisCount: 2,
        children: brailleCells,
    );
  }

  bool isAllRead() {
    return !_read.contains(false);
  }

  setNextCell(BrailleCell nextCell) {
    next = nextCell;
  }

  GridView getBrailleCell() {
    return _brailleCell;
  }

}

