import 'package:desktop2/components/probando.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 179, 141, 170),
      
      body: Center(
        child:ElevatedButton(onPressed: (){
          Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Menu()),
  );
        }, child: Text("Iniciar Sesión")),
      ),
    );
  }
}
