import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './ui/camera.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  final frontCamera = cameras.first;
 // runApp(VibraBraille());
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TakePictureScreen(
        camera: frontCamera,
        ),
      )
  );

}


