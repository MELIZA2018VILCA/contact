import 'dart:async';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact/widgets/my_snackbar.dart';
import 'package:flutter/material.dart';
// paquete para lanzar las llamadas
import 'package:url_launcher/url_launcher.dart';

class HomePageController {
  // context de nuestro "home page"
  late BuildContext context;
  // funcion para cambiar refrescar nuestra app
  late Function refresh;
  // timer que esperar que el usuario deje de escribir para realizar la busqueda
  Timer? searchStopTyping;
  // nombre del usuario a buscar
  late String userName = '';
  // referencide a nuestra colleccion contacto de Firebase
  late CollectionReference contactReferences;
//
  Future<void>? _launched;

  // controladores de los inputs para agregar un contacto
  final nombreUser = TextEditingController();
  final emailUser = TextEditingController();
  final telefonoUser = TextEditingController();

  // funcion para inicializar el context u la funcion refresh del setstate
  void init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    contactReferences = FirebaseFirestore.instance.collection('contacto');

    refresh();
  }

  // funcion para buscar un usuario
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

// funcion para agregar un usuario
  Future<bool> agregarContacto() async {
    final nombre = nombreUser.text;
    final telefono = telefonoUser.text;
    final email = emailUser.text;

    // validando los datos ingresados

    if (nombre.isEmpty || telefono.isEmpty || email.isEmpty) {
      // widget personalizado quemuestra los mensajes en una ventana flotante
      Flushbar(
        backgroundColor: Colors.red,
        message: 'Todos los campos son obligatorios',
        duration: Duration(seconds: 3),
      ).show(context);
      return false;
    }

    if (telefono.length != 9) {
      Flushbar(
        backgroundColor: Colors.red,
        message: 'El telefono debe contener 9 caracteres num??ricos',
        duration: Duration(seconds: 3),
      ).show(context);
      return false;
    }

    if (!email.contains('@')) {
      Flushbar(
        backgroundColor: Colors.red,
        message: 'Debe ingresar un email valido',
        duration: Duration(seconds: 3),
      ).show(context);
      return false;
    }

    // https://stackoverflow.com/questions/68445392/display-snackbar-on-top-of-alertdialog-widget

    final Map<String, dynamic> datos = {
      'nombre': nombre,
      'telefono': telefono,
      'email': email
    };

    try {
      final value = await contactReferences.add(datos);
      // inspect(value);
      reiniciarFormulario();
      return true;
    } on Exception catch (e) {
      inspect(e);
      return false;
    }
    // log(nombre);
    // log(telefono);
    // log(email);
  }

  Future<bool> eliminarContacto(String id) async {
    try {
      await contactReferences.doc(id).delete();
      MySnackbar.show(context, 'Documento eliminado', isSuccess: true);
      return true;
    } on Exception catch (e) {
      // print(e);
      MySnackbar.show(context, 'No see pudo eliminar el contacto');
      return false;
    }
  }

  void reiniciarFormulario() {
    nombreUser.text = '';
    emailUser.text = '';
    telefonoUser.text = '';
  }

// funcion que  invoca las llamadas
  void llamar(String telefono) {
    launchUrl(Uri(scheme: 'tel', path: telefono.toString()));
  }
}
