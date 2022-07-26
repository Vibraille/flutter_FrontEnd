

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget{
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage>{
  bool _autoCapture = false;
  double _brailleCells = 6;
  bool _brailleCellsExpanded = false;
  double _vibrationIntensity = 3;
  bool _vibrationExpanded = false;
  double _fontSize = 30;
  bool _fontExpanded = false;
  bool _borderHighlight = false;
  bool _keyboardsExpanded = false;
  String _defaultKeyboard = "Standard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ExpansionTile(
                    title: menuText('Number of Braille Cells'),
                    children: <Widget>[
                      //slider,
                      Slider(
                        value: _brailleCells,
                        min: 6,
                        max: 12,
                        divisions: 6,
                        label: _brailleCells.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _brailleCells = value;
                          });
                        },
                      )
                    ],
                    onExpansionChanged: (bool expanded) {
                      setState(() => _brailleCellsExpanded = expanded);
                    },
                  ),

            ExpansionTile(
                  title: menuText('Vibration Intensity'),
                  children: <Widget>[
                  //slider,
                  Slider(
                  value: _vibrationIntensity ,
                  min: 0,
                  max: 100,
                  divisions: 5,
                  label: _vibrationIntensity.round().toString(),
                  onChanged: (value) {
                  setState(() {
                  _vibrationIntensity = value;
                  });
                  },
                  )
                  ],
                  onExpansionChanged: (bool expanded) {
                  setState(() => _vibrationExpanded = expanded);
                  },
                ),

            ExpansionTile(
                  title: menuText('Font Size'),
                  children: <Widget>[
                  //slider,
                  Slider(
                  value: _fontSize,
                  min: 20,
                  max: 50,
                  divisions: 6,
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                  setState(() {
                  _fontSize = value;
                  });
                  },
                  )
                  ],
                  onExpansionChanged: (bool expanded) {
                  setState(() => _fontExpanded = expanded);
                  },
              ),

            ListTile(
              title: menuText('Color Scheme'),
              onTap: () {
              },
            ),

            ExpansionTile(
        title: menuText('Default Notes Keyboard'),
        children: <Widget>[
            keyBoardOption("Standard"),
            keyBoardOption("Braille"),
        ],
        onExpansionChanged: (bool expanded) {
          setState(() => _keyboardsExpanded = expanded);
        },
      ),

            SwitchListTile(
                title: menuText('Border Highlight'),
                value: _borderHighlight ,
                onChanged: (bool value) {
                  setState(() {
                    _borderHighlight  = value;
                  });
                },
              ),

            SwitchListTile(
              title: menuText('Auto Capture'),
              value: _autoCapture,
              onChanged: (bool value) {
                  setState(() {
                  _autoCapture = value;
                });
            },
           )
          ],
        )
    );

  }

  Text menuText(String text) {
    return Text(text,
      textAlign: TextAlign.center,
      semanticsLabel: text,
      style: const TextStyle(height: 2, fontSize: 32,
      ),
    );
  }

  ListTile keyBoardOption(String keyboard) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 80.0, right: 100),
      leading: Radio<String>(
        value: keyboard,
        groupValue: _defaultKeyboard,
        onChanged: (value) {
          setState(() {
            _defaultKeyboard = value!;
          });
        },
      ),
      title: menuText(keyboard),
      onTap: () {},
    );
  }
}