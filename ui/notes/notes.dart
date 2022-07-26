import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../menu/settings.dart';
import '/bloc/notes_bloc.dart';
import '/data/notesData.dart';
import 'note_details.dart';



class NotesPage  extends StatefulWidget {

  const NotesPage({Key? key}) : super(key: key);
  @override
  State<NotesPage> createState() => NotesState();


}

class NotesState extends State<NotesPage> {
  bool isCheckBoxShowing = false;
  List<bool> isChecked = <bool>[];
  List<int> toDelete = <int>[];
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
       body: _buildResult(context),

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
        // add buttons, delete will call method, cancel will set state to showing false

        break;
      case 2:
        Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  Widget _buildResult(BuildContext context) {
    final bloc = NoteBloc();
    return StreamBuilder<List<Note>?>(
      stream: bloc.allNotesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return
              const Text('No notes available', semanticsLabel: "No notes available",
                style: TextStyle(fontSize: 35),);
        }
        return ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: buildNotesList(snapshot.data!, context),
        );
      },
    );
  }


    List<Widget> buildNotesList(List<Note> notes, BuildContext context) {
      List<Widget> noteTiles = <Widget>[];
      for (int i = 0; i < notes.length; i++) {
        Note curNote = notes[i];
        Widget tile = isCheckBoxShowing ?
        CheckboxListTile (
            selected: isChecked[i],
            value: isChecked[i],
            title: Text(curNote.title, semanticsLabel: curNote.title,),
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
          title: Text(curNote.title, semanticsLabel: curNote.title,),
          onTap: () => {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => NoteDetailsPage(note: curNote)))
          });
        noteTiles.add(tile);
      }

      return noteTiles;
    }

    deleteChecked() {
      for (int i = 0; i < toDelete.length; i++) {
        final bloc = NoteBloc();
        // made calls to delete
        bloc.noteId.add(toDelete[i]);
        StreamBuilder<String?>(
            stream: bloc.noteDeleteStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return  const AlertDialog(
                  content: Text('Note Failed to Deleted', semanticsLabel: "Note Failed to Deleted",),
                );
              } else {
                return const AlertDialog(
                    content: Text('Note Deleted Successfully', semanticsLabel: "Note Deleted Successfully")
                );
              }
            }
        );
      }


      setState(() {
        isCheckBoxShowing = false;
      });
      if (toDelete.isNotEmpty) {
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


