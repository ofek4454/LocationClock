import 'package:flutter/material.dart';

class ModeChooser extends StatefulWidget {
  final void Function(bool modeTime) changeMode;

  ModeChooser(this.changeMode);

  @override
  _ModeChooserState createState() => _ModeChooserState();
}

class _ModeChooserState extends State<ModeChooser> {
  bool modeTime = false;
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
            right: modeTime ? screenSize.width * 0.35 : 0,
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
                      modeTime = false;
                    });
                    widget.changeMode(modeTime);
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
                      modeTime = true;
                    });
                    widget.changeMode(modeTime);
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
