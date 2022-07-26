import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu/menu.dart';
import './braille.dart';

// A screen that allows users to take a picture using a given camera.
class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  Future<void> initState() async {
    super.initState();
    // To display the current output from the Camera,
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    // create a CameraController.
    _controller = CameraController( cameras.first,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );


    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _controller.setFlashMode(FlashMode.off);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      drawer: Menu(context).menuDrawer,

      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child:
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 100,
        height: 120,
        child:
        FloatingActionButton(
        enableFeedback: true,
        // Provide an onPressed callback.
        onPressed: () async {
          HapticFeedback.vibrate();
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayBrailleScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt, size: 60,),
      ),

    ));
  }
}

