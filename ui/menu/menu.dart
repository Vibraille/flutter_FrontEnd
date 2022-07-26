import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/ui/User/login.dart';
import 'settings.dart';
import '../notes/notes.dart';

class Menu {
  late Drawer menu;

  Menu(BuildContext context) {
    menu = Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: const EdgeInsets.only(top: 30),
        children: [
          //const DrawerHeader(
          //child: Text('Drawer Header'),
          //),
          ListTile(
            title: menuText('Notes'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotesPage(),
                ),
              );
            },
          ),
          ListTile(
            title: menuText('Settings'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          ListTile(
            
            title: menuText('Tutorial'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              //Navigator.pop(context);
            },
          ),
          ListTile(
            title: menuText('Logout'),
            onTap: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  //title: const Text('Save Note?'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        removePreferences();
                        Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false);

                    },
                      child: const Text('Log out', semanticsLabel: "Log out",),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel', semanticsLabel: "Cancel",),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );


  }
  get menuDrawer => menu;

  Text menuText(String text) {
    return Text(text,
       textAlign: TextAlign.center,
       semanticsLabel: text,
        style: const TextStyle(height: 2, fontSize: 45,
        ),
    );
  }

  removePreferences() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove("email");
    sp.remove("username");
    sp.remove("phone");
    sp.remove("refreshToken");
    sp.remove("accessToken");
  }
}