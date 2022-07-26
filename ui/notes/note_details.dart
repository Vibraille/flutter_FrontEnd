


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/notesData.dart';
import '../braille.dart';

class NoteDetailsPage extends StatefulWidget {
  final Note note;
  const NoteDetailsPage({super.key, required this.note});

  @override
  State<NoteDetailsPage> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  double fontSize = 30;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
  }
//DELETE AND EDIT NOTE
  @override
  Widget build(BuildContext context) {
    Note note = widget.note;
    return Scaffold(
      appBar: AppBar (
            title:  Text(note.title, semanticsLabel: note.title,),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              child: Text("Text" , semanticsLabel: "View note as text"),
            ),
            Tab(
                child: Text("Braille", semanticsLabel: "View note as braille vibration"),
            ),
            Tab(
              child: Text("Braille Text", semanticsLabel: "View note as braille text"),

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
            child: braille(note),
          ),
          Center(
            child: brailleText(note),
          ),
        ],
      ),

    );
  }


  Column text(Note note) {
    setOrientation();
    return Column (
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
        child: ListView( children: [
        Text(note.ascii, semanticsLabel: note.ascii,
        style: TextStyle(fontSize: fontSize))]),
        ),
        changeFontSize(),
      ],

    );
  }

  Container braille(Note note) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height *.12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: BrailleTranslation(note.binary).getBrailleTranslation(), // num of braillecells here
        )
    );
  }

  Column brailleText(Note note) {
    setOrientation();
    return Column (
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView( children: [
            Text(note.braille, semanticsLabel: note.ascii,
                style: TextStyle(fontSize: fontSize))]),
        ),
        changeFontSize(),
      ],
    );
  }

  Row changeFontSize() {
    return Row (
      children: [
        FloatingActionButton(
            enableFeedback: true,
            onPressed: () => {
              HapticFeedback.vibrate(),
              setState (() {
                if (fontSize < 50) fontSize += 2;
              })
            }),

        FloatingActionButton(
            enableFeedback: true,
            onPressed: () => {
              HapticFeedback.vibrate(),
              setState (() {
                if (fontSize > 10) fontSize -= 2;
              })
            }),

      ],
    );
  }

  setOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

}