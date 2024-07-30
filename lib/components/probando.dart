import 'package:desktop2/components/login.dart';
import 'package:desktop2/components/ruteo.dart';
import 'package:desktop2/components/tienda.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Row(
          children: [
            Container(
              width: 80,
              color: Color.fromARGB(255, 231, 211, 211),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // USUARIO
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierColor:
                                const Color.fromARGB(255, 241, 204, 204)
                                    .withOpacity(0.35),
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                surfaceTintColor: Colors.amber,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: EdgeInsets.all(15),
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                          child: Text("Información Personal")),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Pato del Carpio"),
                                          Text("Código empleado: XDFG"),
                                          Text("Zona Trabajo: Arequipa")
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 49,
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Cerrar")),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      icon:
                          Icon(Icons.person_outline_sharp, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 30),
                  //RUTEO
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _navigatorKey.currentState?.pushReplacement(
                          CupertinoPageRoute(builder: (context) => Ruteo()),
                        );
                      },
                      icon: Icon(Icons.drive_eta_outlined),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // TIENDITA
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _navigatorKey.currentState?.pushReplacement(
                          CupertinoPageRoute(builder: (context) => Tienda()),
                        );
                      },
                      icon: Icon(Icons.storefront_outlined),
                    ),
                  ),
                  // SALIR
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                            icon: Icon(Icons.exit_to_app)),
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ))
                ],
              ),
            ),
            Expanded(
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (routeSettings) {
                  return CupertinoPageRoute(
                    builder: (context) => Ruteo(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
