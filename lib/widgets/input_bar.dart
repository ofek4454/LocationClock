import 'package:flutter/material.dart';

class InputBar extends StatelessWidget {
  final Future<void> Function(String val) search;

  InputBar(this.search);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.03,
          vertical: screenSize.height * 0.005), // ריווח בר החיפוש
      shape: RoundedRectangleBorder(
        // עיצוב בר החיפוש בקצוות מעוגלים
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8, // צל בר החיפוש כ8 פיקסלים
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextField(
          style: TextStyle(color: Colors.black, fontSize: 16.0),
          decoration: InputDecoration(
            // עיצוב בר החיפוש
            border: InputBorder.none, // ללא מסגרת
            hintText: 'איפה תרצה להתעורר?',
            suffixIcon: Icon(Icons.search), // אייקון של זכוכית מגדלת בסוף הבר
          ),
          onSubmitted: (value) => search(value),
        ),
      ),
    );
  }
}
