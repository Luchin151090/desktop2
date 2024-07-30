import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Rutas extends StatefulWidget {
  const Rutas({Key? key}) : super(key: key);

  @override
  State<Rutas> createState() => _RutasState();
}

class _RutasState extends State<Rutas> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                const Text("Ver",style: TextStyle(
                  color: Colors.white,fontWeight: FontWeight.bold
                ),),
                Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 74, 46, 96),
                      borderRadius: BorderRadius.circular(20)),
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
            const SizedBox(width: 30),
             Text(
              "Rutas en curso",
              style: TextStyle(fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.height/40),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            //color: Color.fromARGB(255, 206, 161, 195)
          ),
          width: MediaQuery.of(context).size.width / 8,
          height: MediaQuery.of(context).size.height / 1.15,
          child: 2 > 0
              ? ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 150,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 214, 214, 214),
                      ),
                      child: Center(
                          child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Ruta Pato'),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.visibility)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.warehouse))
                            ],
                          ),
                          Row(
                            children: [
                              Text("Conductor: $index"),
                              const SizedBox(
                                width: 20,
                              ),
                              const Text(
                                "20",
                                style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Vehículo: $index"),
                              const SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.delete))
                                ],
                              )
                            ],
                          )
                        ],
                      )),
                    );
                  })
              : Container(
                  child: const Center(
                      child: Text(
                    "No hay rutas chiveras.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
        ),
      ],
    );
  }
}
