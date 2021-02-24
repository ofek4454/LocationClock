import 'package:flutter/material.dart';
import 'package:locationAlarm/controller.dart';
import 'package:provider/provider.dart';

class ModeChooser extends StatefulWidget {
  final void Function(WakeUpBy modeTime) changeMode;

  ModeChooser(this.changeMode);

  @override
  _ModeChooserState createState() => _ModeChooserState();
}

class _ModeChooserState extends State<ModeChooser> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      height: screenSize.height * 0.05,
      width: screenSize.width * 0.7,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            right:
                Provider.of<AppController>(context, listen: false).wakeUpBy ==
                        WakeUpBy.Time
                    ? screenSize.width * 0.35
                    : 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.withOpacity(0.5),
              ),
              height: screenSize.height * 0.05,
              width: screenSize.width * 0.35,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      widget.changeMode(WakeUpBy.Distance);
                    });
                  },
                  child: Center(
                    child: Text('לפי מרחק'),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      widget.changeMode(WakeUpBy.Time);
                    });
                  },
                  child: Center(
                    child: Text('לפי זמן'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
