import 'package:flutter/material.dart';
import '/bloc/bloc_provider.dart';
import '/bloc/notes_bloc.dart';
import '/data/notesData.dart';
import './settings.dart';

class NotesPage  extends StatelessWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   // final bloc = BlocProvider.of<NoteListBloc>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Notes'),
            actions: [ PopupMenuButton<int>(
          //color: Colors.black,
          itemBuilder: (context) => [
            const PopupMenuItem<int>(value: 0, child: Text("New Note", semanticsLabel: "New Note",)),
            const PopupMenuDivider(),
            const PopupMenuItem<int>(
                value: 1, child: Text("Delete Note", semanticsLabel: "Delete Note",)),
            const PopupMenuDivider(),
            PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: const [
                    SizedBox(
                      width: 7,
                    ),
                    Text("Settings", semanticsLabel: "Settings",)
                  ],
                )),

        ],
        onSelected: (item) => selectedItem(context, item),
        ),
       ],
    /*   body: Column(
        children: <Widget>[
      Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search Notes Title',
              ),
              onChanged: bloc.searchQuery.add,
            ),
          ),
         Expanded(
            child: _buildResults(bloc),

        ],
      ),*/
        )
    );

  }

/*
  Widget _buildResults(NoteListBloc bloc) {
    // 1
    return StreamBuilder<List<Note>?>(
      stream: bloc.noteStream,
      builder: (context, snapshot) {
        // 2
        final results = snapshot.data;
        if (results == null) {
          return const Center(child: CircularProgressIndicator());
        } else if (results.isEmpty) {
          return const Center(child: Text('No Results'));
        }
        // 3
        return _buildSearchResults(results);
      },
    );
  }

  Widget _buildSearchResults(List<Note> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return InkWell(
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            //child: ArticleListItem(article: article),
          ),
          onTap: () {
           /* Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  bloc: ArticleDetailBloc(id: article.id),
                  child: const ArticleDetailScreen(),
                ),
              ),
            ); */
          },
        );
      },
    );
  }

*/
  void selectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        //Navigator.of(context)
          //  .push(MaterialPageRoute(builder: (context) => SettingPage()));
        break;
      case 1:
       // print("Privacy Clicked");
        break;
      case 2:

       // Navigator.of(context).pushAndRemoveUntil(
         //   MaterialPageRoute(builder: (context) => LoginPage()),
           //     (route) => false);
        Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }
}



