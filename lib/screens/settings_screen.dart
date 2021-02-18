import 'package:flutter/material.dart';
import 'package:locationAlarm/widgets/mode_chooser.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _modeTime = false;

  void changeMode(bool modeTime) {
    setState(() {
      _modeTime = modeTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Text(
              'אני רוצה להתעורר לפי?',
              style: Theme.of(context).textTheme.headline6,
            ),
            ModeChooser(changeMode),
            if (_modeTime) Text('לפי זמן'),
            if (!_modeTime) Text('לפי מרחק'),
          ],
        ),
      ),
    );
  }
}
