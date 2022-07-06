
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DisplayBrailleScreen extends StatefulWidget {
  final String imagePath;
  const DisplayBrailleScreen({super.key, required this.imagePath});

  @override
  State<DisplayBrailleScreen> createState() => _DisplayBrailleScreenState();
}


class _DisplayBrailleScreenState extends State<DisplayBrailleScreen> {

  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Braille Page')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(widget.imagePath)),
      bottomSheet: popUp(context),
    );
  }

  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}


TextButton popUp(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          //title: const Text('Save Note?'),
          content: const Text('Save to notes?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Edit'),
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'Save'),
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
      child: const Text('Show Dialog'),
    );

}


