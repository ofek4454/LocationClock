import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:locationAlarm/controller.dart';
import 'package:locationAlarm/screens/map_screen.dart';
import 'package:locationAlarm/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
        return MapScreen();
        break;
      case 1:
        return SettingsScreen(() => setState(() {
              _currentIndex = 0;
            }));
        break;

      default:
        return MapScreen();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppController>(context, listen: false);
    if (controller.wakeUpBy == null) {
      controller.loadData();
    }
    return Scaffold(
      bottomNavigationBar: BubbleBottomBar(
        hasNotch: true,
        hasInk: true, // מוסיף אפקט ספלאש בעת לחיצה
        backgroundColor: Colors.white, // צבע רקע לבן
        opacity: .2, // נותן לזה אפקט שקיפות
        currentIndex: _currentIndex, // מגדיר את המיקום הנבחר למיקום שבחרנו
        onTap:
            changePage, // ברגע הלחיצה על אחד מהפריטים ישנה את העמוד בהתאם לפריט הנלחץ
        elevation: 10, // מוסיף אפקט של צל
        // רשימת הפריטים
        items: <BubbleBottomBarItem>[
          // פריט זה מייצג את דף הבית
          // ישלו אייקון של בית וכיתוב "מסך הבית" וצבעים בהתאם לצבעי הפליקציה
          // ברגע הלחיצה יופיע דף הבית
          BubbleBottomBarItem(
            backgroundColor: Theme.of(context).accentColor,
            icon: Icon(
              Icons.map,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.map,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'מפה',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: Theme.of(context).accentColor,
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.settings,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'הגדרות',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: _getPage(),
    );
  }
}
