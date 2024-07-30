import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Tiemporeal extends StatefulWidget {
  const Tiemporeal({Key? key}) : super(key: key);

  @override
  State<Tiemporeal> createState() => _TiemporealState();
}

class _TiemporealState extends State<Tiemporeal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Tiempo Real",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height / 35),
        ),
        Container(
          padding: EdgeInsets.all(8),

          //color: Colors.grey,
          height: MediaQuery.of(context).size.height / 1.1,
          width: 250,
          // margin: EdgeInsets.all(5),
          child: ListView.builder(
              itemCount: 900,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: [
                    Container(
                      height: 100,
                      width: 150,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 179, 134, 176)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20)),
                      margin: const EdgeInsets.all(10),
                      child: const Text(
                        "Pedido X :",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 188, 168, 192),
                          borderRadius: BorderRadius.circular(50)),
                      child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              5.5,
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      padding: const EdgeInsets.all(11),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Center(
                                              child: const Text(
                                            "Ruta",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                          StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setState) {
                                            return Text("no");
                                            /* return DropdownButton(
                                                                        hint: const Text(
                                                                            'Vehículos'),
                                                                        value:
                                                                            selectedVehiculo,
                                                                        items: vehiculos.map((Vehiculo
                                                                            auto) {
                                                                          return DropdownMenuItem<
                                                                              Vehiculo>(
                                                                            value:
                                                                                auto,
                                                                            child:
                                                                                Text("${auto.nombre_modelo}"),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (Vehiculo?
                                                                                newValue) {
                                                                          setState(
                                                                              () {
                                                                            selectedVehiculo =
                                                                                newValue;
                                                                          });
                                                                        },
                                                                      );*/
                                          }),
                                          Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Cancelar")),
                                                    ElevatedButton(onPressed: (){},
                                                    style: ButtonStyle(
                                                      
                                                      backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 129, 96, 135))
                                                    ),
                                                     child: Text("Confirmar",style: TextStyle(
                                                      color: Colors.white
                                                     ),))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          icon: const Icon(
                            Icons.add,
                            size: 25,
                            color: const Color.fromARGB(255, 255, 230, 0),
                          )),
                    ),
                  ],
                );
              }),
        )
      ],
    );
  }
}
