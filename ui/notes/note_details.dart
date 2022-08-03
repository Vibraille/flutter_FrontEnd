import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/bloc/notes_bloc.dart';
import '../../data/notesData.dart';
import '../braille.dart';

class NoteDetailsPage extends StatefulWidget {
  final Note note;
  final SharedPreferences sp;
  const NoteDetailsPage({super.key, required this.note, required this.sp});

  @override
  State<NoteDetailsPage> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _titleController;
  double fontSize = 50;
  late String title;


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _titleController = TextEditingController(text: widget.note.title);
    _tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() => {
          title = title
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    Note note = widget.note;
    title = note.title;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: changeFontSize(),
      appBar: AppBar (toolbarHeight: 35, centerTitle: true,
            title: GestureDetector(
                onTap: () {
                    changeTitle(note.noteId);
                  },
                child: Text(title, semanticsLabel: title,
                  style: const TextStyle(fontSize: 30), textAlign: TextAlign.center,),
            ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(child: Text("Text" , semanticsLabel: "View note as text",
                style: TextStyle(fontSize: 22)),
            ),
            Tab(child: Text("Braille Text", semanticsLabel: "View note as braille text",
                style: TextStyle(fontSize: 21)),
            ),
            Tab( child: Text("Braille", semanticsLabel: "View note as braille vibration",
                style: TextStyle(fontSize: 22)),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(
            child: text(note),
          ),
          Center(
            child: brailleText(note),
          ),
          Center(
            child: braille(note),
          ),
        ],
      ),

    );
  }


  Wrap text(Note note) {
    return Wrap( children: [
    SizedBox(height: MediaQuery.of(context).size.height,
        child: ListView( children: [
        Text(note.ascii, semanticsLabel: note.ascii,
        style: TextStyle(fontSize: fontSize))]),
        ),
        // changeFontSize(),
      ],

    );
  }
  Wrap brailleText(Note note) {
    return Wrap ( children: [ SizedBox(
          height: MediaQuery.of(context).size.height * 90,
          child: ListView( children: [
            Text(note.braille, semanticsLabel: note.ascii,
                style: TextStyle(fontSize: fontSize))]),
        ),
        // changeFontSize(),
      ],
    );
  }

  Container braille(Note note) {
    return Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height *.05),
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: BrailleTranslation(note.binary).getBrailleTranslation(), // num of braillecells here
        )
    );
  }

  changeTitle(int id) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('Edit Title',
                semanticsLabel: "Edit title name"),
            content: TextField(controller: _titleController,
                onChanged: (value) => {
                  title = value,
                }
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => {
                  Navigator.pop(context, 'Save'),
                  SetTitle(context, title, id, widget.sp),
                }, // pop context
                child: const Text(
                  'Save', semanticsLabel: "Save title ",),
              ),
              TextButton(
                onPressed: () => {
                  Navigator.of(context).pop(),
                },
                child: const Text('Cancel', semanticsLabel: "Cancel",),
              ),
            ],
          ),
    );
  }


  Row changeFontSize() {
    return Row (
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
            onPressed: () => {
              HapticFeedback.vibrate(),
              setState (() {
                 if (fontSize > 20) fontSize -= 5;
              })
            },
            child: const Icon(Icons.remove, size: 50)),
            const Padding(padding: EdgeInsets.only(right: 20)),
        FloatingActionButton(
            onPressed: () => {
              HapticFeedback.vibrate(),
              setState (() {
                if (fontSize < 150) fontSize += 5;
              })
            },
            child: const Icon(Icons.add, size: 50)),
        const Padding(padding: EdgeInsets.only(right: 10)),
      ],
    );
  }

  // setOrientation() {
  //   if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
  //     // setState(() => {
  //       log(_tabController.index.toString());
  //       if (_tabController.index == 2) {
  //         SystemChrome.setPreferredOrientations([
  //           DeviceOrientation.landscapeRight,
  //           DeviceOrientation.landscapeLeft,
  //         ]);
  //       } else{
  //           SystemChrome.setPreferredOrientations([
  //             DeviceOrientation.portraitUp,
  //             DeviceOrientation.portraitDown,
  //           ]);
  //       }
  //     // });
  //   }
  // }

  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

}

class SetTitle {
  SetTitle(BuildContext context, String newTitle, int id , SharedPreferences sp) {
    log(newTitle);
    final bloc = NoteBloc(sp);
    bloc.noteChange.add([id.toString(), newTitle]);
    WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<Note?>(
            stream: bloc.noteEditStream,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return const Text("Title changed", semanticsLabel: "title changed",
                  style: TextStyle(fontSize: 30),);
              }
              return const Center(child: CircularProgressIndicator());
            });
      },
    );});
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

}