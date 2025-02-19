import 'package:flutter/material.dart';

class SmartServeHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "SmartServe",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue, // Change color as needed
      elevation: 4, // Adds shadow
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0); // AppBar height
}
