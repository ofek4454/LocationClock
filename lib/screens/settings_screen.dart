import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locationAlarm/widgets/mode_chooser.dart';
import 'package:provider/provider.dart';

import '../controller.dart';

class SettingsScreen extends StatefulWidget {
  final Function moveToMap;

  SettingsScreen(this.moveToMap);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void initState() {
    super.initState();
  }

  void changeMode(WakeUpBy wakeUpBy) {
    setState(() {
      Provider.of<AppController>(context, listen: false).wakeUpBy = wakeUpBy;
    });
  }

  void save(String val) {
    Provider.of<AppController>(context, listen: false).saveSettings(val);
    widget.moveToMap();
  }

  Widget _buildTimeModeContent() {
    final controller = TextEditingController();
    controller.text =
        '${Provider.of<AppController>(context, listen: false).timeToWake}';
    return Container(
      child: Expanded(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('הער אותי '),
                Container(
                  width: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    controller: controller,
                    maxLines: 1,
                    maxLength: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(' דקות לפני שנגיע'),
              ],
            ),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: () => save(controller.text),
              child: Text('שמור'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceModeContent() {
    final controller = TextEditingController();
    controller.text =
        '${Provider.of<AppController>(context, listen: false).distanceToWake}';
    return Container(
      child: Expanded(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('הער אותי '),
                Container(
                  width: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    controller: controller,
                    maxLines: 1,
                    maxLength: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(' ק״מ לפני שנגיע'),
              ],
            ),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: () => save(controller.text),
              child: Text('שמור'),
            )
          ],
        ),
      ),
    );
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
            Provider.of<AppController>(context, listen: false).wakeUpBy ==
                    WakeUpBy.Time
                ? Text('לפי זמן')
                : Text('לפי מרחק'),
            Provider.of<AppController>(context, listen: false).wakeUpBy ==
                    WakeUpBy.Time
                ? _buildTimeModeContent()
                : _buildDistanceModeContent(),
          ],
        ),
      ),
    );
  }
}
