import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class Tienda extends StatefulWidget {
  const Tienda({Key? key}) : super(key: key);

  @override
  State<Tienda> createState() => _TiendaState();
}

class _TiendaState extends State<Tienda> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 167, 183, 148),
      
      body: Center(
        child: Text('Tienda'),
      ),
    );
  }
}