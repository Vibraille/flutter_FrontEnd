import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../menu/settings.dart';
import '/bloc/notes_bloc.dart';
import '/data/notesData.dart';
import 'note_details.dart';



class NotesPage  extends StatefulWidget {
  final SharedPreferences sp;
  const NotesPage({super.key, required this.sp});
  @override
  State<NotesPage> createState() => NotesState();


}

class NotesState extends State<NotesPage> {
  bool isCheckBoxShowing = false;
  late List<bool> isChecked;
  List<int> toDelete = <int>[];
  List<Note>? allNotes;


  @override
  void initState() {
    super.initState();
  }
  // DELETE NOTES multiple at a time
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Notes'),
            actions: [ PopupMenuButton<int>(
          itemBuilder: (context) => [
            const PopupMenuItem<int>(value: 0, child: Text("New Note", semanticsLabel: "New Note",
                style: TextStyle(fontSize: 35))),
            const PopupMenuDivider(),
            const PopupMenuItem<int>(
                value: 1, child: Text("Delete Note", semanticsLabel: "Delete Note",
                style: TextStyle(fontSize: 35))),
            const PopupMenuDivider(),
            PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: const [
                    SizedBox(
                      width: 7,
                    ),
                    Text("Settings", semanticsLabel: "Settings", style: TextStyle(fontSize: 35))
                  ],
                )),

        ],
        onSelected: (item) => selectedItem(context, item),
        ),
       ]),
       body: allNotes == null ?  _buildResult(context) : buildNotesList(allNotes!, context),
        bottomNavigationBar: SizedBox(
          height: isCheckBoxShowing ? 50: 0,
       child: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton(
                          child: const Text('Delete', semanticsLabel: "Delete",
                            style: TextStyle(fontSize: 25),),
                          onPressed: () => {
                            deleteChecked(),
                            setState(() {
                              isCheckBoxShowing = false;
                            }),
                          }
                      ), const Padding(padding: EdgeInsets.only(left: 20, right: 20)),
                      ElevatedButton(
                          child: const Text('Cancel', semanticsLabel: "Cancel",
                          style: TextStyle(fontSize: 25),),
                          onPressed: () => {
                            setState(() {
                              isCheckBoxShowing = false;
                            }),
                          }
                      )],
                  )
        ),)
    );

  }

  void selectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        showDialog(
            context: context,
            builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('New Note', semanticsLabel: "New note tab",
              style: TextStyle(fontSize: 30),),
            content: const Text('Feature coming soon!',
              semanticsLabel: "Feature coming soon!",
              style: TextStyle(fontSize: 25),),
            actions: <Widget>[
              TextButton(
                onPressed: () =>  { Navigator.pop(context, 'Cancel')
                },
                child: const Text('Okay', semanticsLabel: "Okay", style: TextStyle(fontSize: 25),),
              )]
        );});
        break;
      case 1:

        setState(() {
          isCheckBoxShowing = true;
        });
        log(isCheckBoxShowing.toString());
        break;
      case 2:
        Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  Widget _buildResult(BuildContext context) {
      final bloc = NoteBloc(widget.sp);
      bloc.getNotes.add("");
      return StreamBuilder<List<Note>?>(
        stream: bloc.allNotesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == null) {
            return Container(padding: const EdgeInsets.only(left: 10, top: 15),
                child: const Text(
                    'No notes available', semanticsLabel: "No notes available",
                    style: TextStyle(fontSize: 35)));
          } else {
            isChecked = List.filled(snapshot.data!.length, false);
            allNotes = snapshot.data!;
            return buildNotesList(snapshot.data!, context);

          }
        },
      );

  }


    ListView buildNotesList(List<Note> notes, BuildContext context) {
      List<Widget> noteTiles = <Widget>[];
      for (int i = 0; i < notes.length; i++) {
        Note curNote = notes[i];
        Widget tile = isCheckBoxShowing ?
        CheckboxListTile (
           // selected: isChecked[i],
            value: isChecked[i],
            title: Text(curNote.title, semanticsLabel: curNote.title,
              style: const TextStyle(fontSize: 50),textAlign: TextAlign.center,),
            enableFeedback: true,
            onChanged: (value) {
                    HapticFeedback.vibrate();
                    setState(() {
                          isChecked[i] = value!;
                          int id = curNote.noteId;
                          if (isChecked[i]) {
                            toDelete.add(id);
                          } else {
                            toDelete.remove(id);
                          }
                    });
            }) :
          ListTile (
            contentPadding: const EdgeInsets.only(bottom: 10),
          title: Text(curNote.title, semanticsLabel: curNote.title,
                    style: const TextStyle(fontSize: 50),textAlign: TextAlign.center,),
          onTap: () => {
            setState(() {
              allNotes = null;
            }),
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => NoteDetailsPage(note: curNote, sp: widget.sp)))
          });
        noteTiles.add(tile);
      }
      return  ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: noteTiles,
      );
    }

    deleteChecked() {
    log(toDelete.toString());
      for (int i = 0; i < toDelete.length; i++) {
        //allNotes!.remove(toDelete[i]);
        final bloc = NoteBloc(widget.sp);
        // made calls to delete
        bloc.noteId.add(toDelete[i]);
        log("to delete");
        log(toDelete[i].toString());
        WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
            context: context,
            builder: (BuildContext context) {
              return StreamBuilder<String?>(
            stream: bloc.noteDeleteStream,
            builder: (context, snapshot) {
                return const Center(child: CircularProgressIndicator());
            }
        );},
        );});
        log("delay2");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
      Future.delayed(const Duration(seconds: 3), () {
      });
      if (toDelete.isNotEmpty) {
        setState(() {
          isCheckBoxShowing = false;
          toDelete.clear();
          allNotes = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected Notes Deleted', semanticsLabel: "Selected Notes Deleted",),
          ),
        );
      }

    }


  @override
  void dispose() {
    super.dispose();
  }
}


