import 'dart:async';

import 'package:flutter/material.dart';

class HomePageController {
  late BuildContext context;
  late Function refresh;
  Timer? searchStopTyping;
  late String userName = '';

  void init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;

    refresh();
  }

  void onChangedText(String texto) {
    Duration duracion = Duration(milliseconds: 800);
    if (searchStopTyping != null) {
      searchStopTyping?.cancel();
      refresh();
    }
    searchStopTyping = Timer(duracion, () {
      userName = texto;
      refresh();
      // print(texto);
    });
  }
}
