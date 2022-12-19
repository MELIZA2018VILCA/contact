import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact/pages/home_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:gap/gap.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controlador = HomePageController();
  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controlador.init(context, refresh);
    });
  }

  final CollectionReference contactReferences =
      FirebaseFirestore.instance.collection('contacto');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: AppBar(
          title: Text('Contact App'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.amber,
          // backgroundColor: Colors.white,
          // actions: [
          //   GestureDetector(
          //     onTap: () => controlador.openDrawer(context),
          //     child: Padding(
          //       padding: EdgeInsets.only(right: 30.0),
          //       child: Icon(
          //         CupertinoIcons.text_alignleft,
          //         color: Colors.white,
          //         size: 30.0,
          //       ),
          //     ),
          //   ),
          // ],
          flexibleSpace: Container(
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     // stops: [0.5, 0.6],
            //     colors: [Color(0xff141E30), Color(0xff243B55)],
            //   ),
            // ),
            child: Column(
              children: [
                Gap(55),
                _SearchWidget(
                  controlador: controlador,
                )
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: contactReferences.snapshots(),
          // initialData: initialData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // inspect(snapshot);
            if (snapshot.hasData) {
              QuerySnapshot collection = snapshot.data;
              List<QueryDocumentSnapshot> docs = collection.docs;
              List<Map<String, dynamic>> docMap = docs.map((e) {
                return e.data() as Map<String, dynamic>;
              }).toList();
              return ListView.builder(
                itemCount: docMap.length,
                itemBuilder: ((context, int i) {
                  return Dismissible(
                    key: Key(snapshot.data.docs[i].reference.id.toString()),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: const [
                              Color.fromARGB(255, 229, 145, 145),
                              // Color(0xffCC527A),
                              // Color(0xffE8175D),
                              Color.fromARGB(255, 221, 42, 42),
                              Color.fromARGB(255, 236, 7, 7),
                            ],
                            // stops: [0.4, 0.6],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 20.0),
                            Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                    confirmDismiss: (_) {
                      return showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text('Eliminar Contacto 🙀'),
                              content: Text(
                                  'Un contacto eliminado no podra ser recuperado.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    log('documento eliminado: ${snapshot.data.docs[i].reference.id.toString()}');
                                    // bool respuesta =
                                    //     await controlador.crearUsuarioDelivery(
                                    //         usuario.id as String);
                                    // Navigator.pop(context, respuesta);
                                    // if (respuesta == true) {
                                    //   refresh();
                                    // }
                                    Navigator.pop(context, true);
                                  },
                                  child: Text('Elimnar'),
                                ),
                              ],
                            );
                          });
                    },
                    direction: DismissDirection.endToStart,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.indigo,
                        child: Text(
                          docMap[i]['nombre'].substring(0, 2),
                        ),
                      ),
                      title: Text(
                        docMap[i]['nombre'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        color: Colors.green,
                        icon: Icon(
                          CupertinoIcons.phone_arrow_right,
                        ),
                        onPressed: () {
                          log(docMap[i]['telefono']);
                        },
                      ),
                    ),
                  );
                }),
              );
            }
            return LinearProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: IconButton(
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AlertDialog(
                      scrollable: true,
                      title: Text('Login'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: [
                              TextField(
                                controller: controlador.nombreUser,
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  icon: Icon(Icons.account_box),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                controller: controlador.emailUser,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  icon: Icon(Icons.email),
                                ),
                              ),
                              TextField(
                                keyboardType: TextInputType.phone,
                                controller: controlador.telefonoUser,
                                decoration: InputDecoration(
                                  labelText: 'teléfono',
                                  icon: Icon(Icons.phone),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            bool respuesta =
                                await controlador.agregarContacto();
                            // bool respuesta =
                            //     await controlador.crearUsuarioDelivery(
                            //         usuario.id as String);
                            if (respuesta == true) {
                              Navigator.pop(context);
                              // refresh();
                            }
                          },
                          child: Text('Confirmar'),
                        ),
                      ],
                    ),
                  );
                }),
            icon: Icon(
              CupertinoIcons.add_circled,
            )),
      ),
    );
  }
}

class _SearchWidget extends StatelessWidget {
  const _SearchWidget({
    Key? key,
    required this.controlador,
  }) : super(key: key);

  final HomePageController controlador;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0).copyWith(top: 17.0),
      child: TextField(
        onChanged: (texto) => controlador.onChangedText(texto),
        decoration: InputDecoration(
          hintText: 'Buscar Usuario...',
          suffixIcon: Icon(CupertinoIcons.search, color: Colors.white),
          hintStyle: TextStyle(
            fontSize: 17.0,
            color: Colors.grey[100],
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.white),
            // borderSide: BorderSide(color: Colors.grey.withOpacity(0.9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.grey, width: 0.2),
          ),
          contentPadding: EdgeInsets.all(15.0),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
