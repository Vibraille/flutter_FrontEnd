
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/ui/camera.dart';
import 'package:vibra_braille/ui/user/login.dart';

Future<void> main() async{

  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      )
  );

}





