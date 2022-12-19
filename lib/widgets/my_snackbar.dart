import 'package:flutter/material.dart';

class MySnackbar {
  static void show(BuildContext? context, String? texto,
      {bool isSuccess = false}) {
    if (context == null) return;
    // print(context);
    FocusScope.of(context).requestFocus(FocusNode());
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          texto!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        backgroundColor: !isSuccess ? Colors.red[400] : Colors.green[400],
        duration: Duration(seconds: 3),
      ),
    );
  }
}
