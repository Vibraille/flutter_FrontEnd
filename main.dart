
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vibra_braille/ui/auth/login.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      )
  );

}





