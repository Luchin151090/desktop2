import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*"conductor_id": 1,
			"vehiculo_id": 1,
			"empleado_id": 1,
			"distancia_km": 0,
			"tiempo_ruta": 0,
			"fecha_creacion": "2024-07-31T19:58:07.279Z"*/
class PedidoRuta {
  final int id;
  final int ruta_id;
  final String nombre_cliente;
  final String apellidos_cliente;
  final String telefono_cliente;
  final double total;
  final String fecha;
  final String tipo;
  final String distrito;
  final String direccion;

  PedidoRuta(
      {required this.id,
      required this.ruta_id,
      required this.nombre_cliente,
      required this.apellidos_cliente,
      required this.telefono_cliente,
      required this.total,
      required this.fecha,
      required this.tipo,
      required this.distrito,
      required this.direccion});
}

class Ruta {
  final int id;
  final int conductorid;
  final int vehiculoid;
  final int empleadoid;
  final int distanciakm;
  final int tiemporuta;
  Ruta(
      {required this.id,
      required this.conductorid,
      required this.vehiculoid,
      required this.empleadoid,
      required this.distanciakm,
      required this.tiemporuta});
}

class Vehiculo {
  final int id;
  final String nombre_modelo;
  final String placa;
  final int administrador_id;

  bool seleccionado;
  Vehiculo(
      {required this.id,
      required this.nombre_modelo,
      required this.placa,
      required this.administrador_id,
      this.seleccionado = false});
}

class Conductor {
  final int id;
  final String nombres;
  final String apellidos;
  final String licencia;
  final String dni;
  final String fecha_nacimiento;

  bool seleccionado; // Nuevo campo para rastrear la selección

  Conductor(
      {required this.id,
      required this.nombres,
      required this.apellidos,
      required this.licencia,
      required this.dni,
      required this.fecha_nacimiento,
      this.seleccionado = false});
}

class Pedido {
  final int id;
  int? ruta_id; // Puede ser nulo// Puede ser nulo
  final double subtotal; //
  final double descuento;
  final double total;

  final String fecha;
  final String tipo;
  String estado;
  String? observacion;

  double? latitud;
  double? longitud;
  String? distrito;

  // Atributos adicionales para el caso del GET
  final String nombre; //
  final String apellidos; //
  final String telefono; //

  bool seleccionado; // Nuevo campo para rastrear la selección

  Pedido(
      {required this.id,
      this.ruta_id,
      required this.subtotal,
      required this.descuento,
      required this.total,
      required this.fecha,
      required this.tipo,
      required this.estado,
      this.observacion,
      required this.latitud,
      required this.longitud,
      this.distrito,
      // Atributos adicionales para el caso del GET
      required this.nombre,
      required this.apellidos,
      required this.telefono,
      this.seleccionado = false});
}

class Rutas extends StatefulWidget {
  const Rutas({Key? key}) : super(key: key);

  @override
  State<Rutas> createState() => _RutasState();
}

class _RutasState extends State<Rutas> {
  List<Pedido> nuevopedidodistrito = [];
  Map<String, List<Pedido>> distrito_pedido = {};
  List<String> distrito_de_pedido = [];
  Set<String> distritosSet = {};

  Vehiculo? selectedVehiculo;
  Conductor? selectedConductor;

  final List<String> colors = [
    'Blue',
    'Pink',
    'Green',
    'Orange',
    'Grey',
  ];
  TextEditingController _text1 = TextEditingController();
  List<Vehiculo> vehiculos = [];
  List<Conductor> conductorget = [];
  late Color colormarcador;
  int idConductor = 0;
  int idVehiculo = 0;
  int rutaIdLast = 0;
  List<int> idPedidosSeleccionados = [];
  int number = 0;
  String api = dotenv.env['API_URL'] ?? '';
  String apipedidos = '/api/pedido';
  String conductores = '/api/user_conductor';
  String rutacrear = '/api/ruta';
  String apiRutaCrear = '/api/ruta';
  String apiLastRuta = '/api/rutalast';
  String apiUpdateRuta = '/api/pedidoruta';
  String apiEmpleadoPedidos = '/api/empleadopedido/';
  String apiVehiculos = '/api/vehiculo/';
  String totalventas = '/api/totalventas_empleado/';
  String allrutasempleado = '/api/allrutas_empleado/';
  String rutapedidos = '/api/ruta/';
  String updatedeletepedido ='/api/revertirpedido/';
  final ScrollController _scrollController3 = ScrollController();
  List<Ruta> rutasempleado = [];
  int numeroruta = 0;
  String mensajedelete = "No procesa";
  List<PedidoRuta> pedidosruta = [];



  List<Pedido> hoypedidos = [];
  List<Pedido> hoyexpress = [];
  List<Pedido> agendados = [];
    late DateTime fechaparseadas;
  late DateTime fechaHoyruta;
  DateTime now = DateTime.now();
  //LISTAS Y VARIABLES
  List<Pedido> pedidosget = [];
  List<Pedido> pedidoSeleccionado = [];



  @override
  void dispose() {
    _scrollController3.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getConductores();
    getVehiculos();
    getallrutasempleado();
    getPedidos();
  }
Future<dynamic> updatePedidoRuta(int ruta_id,String estado) async {
  try{
    /*print("dentro de update ruta");
    print(ruta_id);
    print(idPedidosSeleccionados.length);*/
    for (var i = 0; i < idPedidosSeleccionados.length; i++) {
     /* print("iterando");
      print(idPedidosSeleccionados[i]);*/
      await http.put(
          Uri.parse(
              api + apiUpdateRuta + '/' + idPedidosSeleccionados[i].toString()),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"ruta_id": ruta_id, "estado": estado}));
    }
  }
  catch(error){
    throw Exception("$error");
  }
    
  
}

  Future<dynamic> getPedidos() async {
    try {
      //print("---------dentro ..........................get pedidos");
      //print(apipedidos);
      SharedPreferences empleadoShare = await SharedPreferences.getInstance();

      var empleadoIDs = 1; //empleadoShare.getInt('empleadoID');
      var res = await http.get(
          Uri.parse(api + apipedidos + '/' + empleadoIDs.toString()),
          headers: {"Content-type": "application/json"});

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Pedido> tempPedido = (data as List).map<Pedido>((data) {
          return Pedido(
              id: data['id'],
              ruta_id: data['ruta_id'] ?? 0,
              subtotal: data['subtotal']?.toDouble() ?? 0.0,
              descuento: data['descuento']?.toDouble() ?? 0.0,
              total: data['total']?.toDouble() ?? 0.0,
              fecha: data['fecha'],
              tipo: data['tipo'],
              distrito: data['distrito'],
              estado: data['estado'],
              latitud: data['latitud']?.toDouble() ?? 0.0,
              longitud: data['longitud']?.toDouble() ?? 0.0,
              nombre: data['nombre'] ?? '',
              apellidos: data['apellidos'] ?? '',
              telefono: data['telefono'] ?? '');
        }).toList();

        if (mounted) {
          setState(() {
            pedidosget = tempPedido;
            //print("---pedidos get");
            //print(pedidosget.length);

            // TRAIGO LOS DISTRITOS DE LOS PEDIDOS DE AYER - SOLO LOS DE AYER
            for (var j = 0; j < pedidosget.length; j++) {
              fechaparseadas = DateTime.parse(pedidosget[j].fecha.toString());
              if (pedidosget[j].estado == 'pendiente') {
                if (pedidosget[j].tipo == 'normal' ||
                    pedidosget[j].tipo == 'express') {
                  if (fechaparseadas.day != now.day) {
                    distritosSet.add(pedidosget[j].distrito.toString());
                  }
                }
              }
            }

            // Convertir el Set a una lista
            distrito_de_pedido = distritosSet.toList();
            //print("distritos");
            //print(distrito_de_pedido);

            // AHORA ITERO EN TODOS LOS PEDIDOS Y LO RELACIONO SOLO CON LOS DISTRITOS QUE OBTUVE
            for (var x = 0; x < distrito_de_pedido.length; x++) {
              //print(distrito_de_pedido[x]);
              for (var j = 0; j < pedidosget.length; j++) {
                fechaparseadas = DateTime.parse(pedidosget[j].fecha.toString());
                if (pedidosget[j].estado == 'pendiente') {
                  if (pedidosget[j].tipo == 'normal' ||
                      pedidosget[j].tipo == 'express') {
                    //    print("----------TIPO");
                    // print(pedidosget[j].tipo);
                    if (fechaparseadas.day != now.day) {
                      if (distrito_de_pedido[x] == pedidosget[j].distrito) {
                        nuevopedidodistrito.add(pedidosget[j]);
                        /* print("nuevo pedido distrito ID:");
                        print(pedidosget[j].id);
                        print(pedidosget[j].distrito);
                        print(pedidosget[j].nombre);
                        print(pedidosget[j].apellidos);
                        print(pedidosget[j].tipo);
                        print(pedidosget[j].total);*/
                      }
                    }
                  }
                }
              }
              setState(() {
                distrito_pedido['${distrito_de_pedido[x]}'] =
                    nuevopedidodistrito;
                nuevopedidodistrito = [];
              });
              //print("tamaño de mapa");
              //print(distrito_pedido['${distrito_de_pedido[x]}']?.length);
            }

           /* int count = 1;
            for (var i = 0; i < pedidosget.length; i++) {
              fechaparseadas = DateTime.parse(pedidosget[i].fecha.toString());
              if (pedidosget[i].estado == 'pendiente') {
                if (pedidosget[i].tipo == 'normal' ||
                    pedidosget[i].tipo == 'express') {
                  if (fechaparseadas.day != now.day) {
                    LatLng coordGET = LatLng(
                        (pedidosget[i].latitud ?? 0.0) + (0.000001 * count),
                        (pedidosget[i].longitud ?? 0.0) + (0.000001 * count));
                    puntosget.add(coordGET);
                    pedidosget[i].latitud = coordGET.latitude;
                    pedidosget[i].longitud = coordGET.longitude;
                    agendados.add(pedidosget[i]);
                    //print("......AGENDADOS");
                    //print(agendados);
                  }
                }
              }
              count++;
            }*/

            //marcadoresPut("agendados");
            setState(() {
              number = agendados.length;
            });
            //print("ageng tama");
            //print(number);
          });
        }
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }

  Future<dynamic>deleterevertir(int idpedido) async{
    try{
      var res = await http.delete(Uri.parse(api+updatedeletepedido+idpedido.toString()),
      headers: {"Content-type":"application/json"});
      if(res.statusCode==200){
        setState(() {
          mensajedelete ="Pedido revertido o eliminado";
        });
      }
    }
    catch(error){
      throw Exception("$error");
    }
  }
  Future<dynamic> getpedidosruta(rutaid) async {
    //print("-----ruta---");
    //print(rutaid);
    try {
      var res = await http.get(Uri.parse(api + rutapedidos + rutaid.toString()),
          headers: {"Content-type": "application/json"});
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        //print("rutita--------------");
        //print(data);
        List<PedidoRuta> tempPedido = data.map<PedidoRuta>((data) {
          return PedidoRuta(
              id: data['pedido_id'],
              ruta_id: data['ruta_id'],
              nombre_cliente:data['nombre_cliente'], // cliente_nr_id : 53 //cliente_id : null
              apellidos_cliente: data['apellidos_cliente'],
              telefono_cliente: data['telefono_cliente'],
              total: data['total']?.toDouble() ?? 0.0,
              fecha: data['fecha'].toString(),
              tipo: data['tipo'],
              distrito: data['distrito'],
              direccion: data['direccion']);
        }).toList();
        if (mounted) {
          pedidosruta = tempPedido;
        }
      }
    } catch (error) {
      throw Exception("Error pedidos ruta $error");
    }
  }

  Future<dynamic> getallrutasempleado() async {
    var empleado = 1;
    try {
      var res = await http.get(
          Uri.parse(api + allrutasempleado + empleado.toString()),
          headers: {"Content-type": "application/json"});

      if (res.statusCode == 200) {
        var responseData = json.decode(res.body);
       // print("rutass data");
        //print(responseData['data']);

        // Asegúrate de que responseData['data'] sea una lista antes de usar map
        if (responseData['data'] is List) {
          List<Ruta> temprutasempleado =
              (responseData['data'] as List).map<Ruta>((item) {
            return Ruta(
              id: item['id'],
              conductorid: item['conductor_id'],
              vehiculoid: item['vehiculo_id'],
              empleadoid: item['empleado_id'],
              distanciakm: item['distancia_km'],
              tiemporuta: item['tiempo_ruta'],
            );
          }).toList();

          if (mounted) {
            setState(() {
              rutasempleado = temprutasempleado;
              numeroruta = rutasempleado.length;
            });
          }
        } else {
          print('No se encontraron rutas en la respuesta.');
        }
      } else if (res.statusCode == 404) {
        print('No se encontraron rutas.');
      } else {
        print('Error inesperado: ${res.statusCode}');
      }
    } catch (error) {
      throw Exception("Error de petición: $error");
    }
  }

  Future<dynamic> getConductores() async {
    try {
      SharedPreferences empleadoShare = await SharedPreferences.getInstance();
      var empleadoIDs = 1; //empleadoShare.getInt('empleadoID');
      /*print("El empleado traido es");
      print(empleadoIDs);*/
      var res = await http.get(
          Uri.parse(api + conductores + '/' + empleadoIDs.toString()),
          headers: {"Content-type": "application/json"});

      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Conductor> tempConductor = data.map<Conductor>((data) {
          return Conductor(
              id: data['id'],
              nombres: data['nombres'],
              apellidos: data['apellidos'],
              licencia: data['licencia'],
              dni: data['dni'],
              fecha_nacimiento: data['fecha_nacimiento']);
        }).toList();
        if (mounted) {
          setState(() {
            conductorget = tempConductor;
          });
        }
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<dynamic> getVehiculos() async {
    SharedPreferences empleadoShare = await SharedPreferences.getInstance();
    try {
      // print("...............................URL DE GETVEHICULOS");
      // print(api + apiVehiculos + empleadoShare.getInt('empleadoID').toString());
      var res = await http.get(
          Uri.parse(api +
              apiVehiculos +
              '1'), //empleadoShare.getInt('empleadoID').toString()),
          headers: {"Content-type": "application/json"});
      //print("........................................RES BODY");
      //print(res.body);
      var data = json.decode(res.body);
      //print("......................data vehiculos x empelado");
      //print(data);
      if (data is List) {
        List<Vehiculo> tempVehiculo = data.map<Vehiculo>((item) {
          return Vehiculo(
            id: item['id'],
            nombre_modelo: item['nombre_modelo'],
            placa: item['placa'],
            administrador_id: item['administrador_id'],
          );
        }).toList();

        if (mounted) {
          setState(() {
            vehiculos = tempVehiculo;
          });
        }
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                const Text(
                  "Ver",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height / 45),
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
          height: MediaQuery.of(context).size.height / 1.2,
          child: numeroruta > 0
              ? ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: numeroruta,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 150,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: Center(
                          child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Ruta ${rutasempleado[index].id}'),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.visibility)),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            child: Container(
                                              width:
                                                  400, // Ajusta el tamaño del contenedor principal según tus necesidades
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 5,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('Bidón 20'),
                                                      DropdownButton<int>(
                                                        value: 15,
                                                        items: List.generate(
                                                          30,
                                                          (index) =>
                                                              DropdownMenuItem(
                                                            child: Text(index
                                                                .toString()),
                                                            value: index,
                                                          ),
                                                        ),
                                                        onChanged: (value) {},
                                                      ),
                                                      Text("16"),
                                                      ElevatedButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                            'Confirmar',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('700ml'),
                                                      DropdownButton<int>(
                                                        value: 15,
                                                        items: List.generate(
                                                          30,
                                                          (index) =>
                                                              DropdownMenuItem(
                                                            child: Text(index
                                                                .toString()),
                                                            value: index,
                                                          ),
                                                        ),
                                                        onChanged: (value) {},
                                                      ),
                                                      Text("16"),
                                                      ElevatedButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                            'Confirmar',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('3 Litros'),
                                                      DropdownButton<int>(
                                                        value: 15,
                                                        items: List.generate(
                                                          30,
                                                          (index) =>
                                                              DropdownMenuItem(
                                                            child: Text(index
                                                                .toString()),
                                                            value: index,
                                                          ),
                                                        ),
                                                        onChanged: (value) {},
                                                      ),
                                                      Text("16"),
                                                      ElevatedButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                            'Confirmar',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('7 Litros'),
                                                      DropdownButton<int>(
                                                        value: 15,
                                                        items: List.generate(
                                                          30,
                                                          (index) =>
                                                              DropdownMenuItem(
                                                            child: Text(index
                                                                .toString()),
                                                            value: index,
                                                          ),
                                                        ),
                                                        onChanged: (value) {},
                                                      ),
                                                      Text("16"),
                                                      ElevatedButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                            'Confirmar',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('Recarga'),
                                                      DropdownButton<int>(
                                                        value: 15,
                                                        items: List.generate(
                                                          30,
                                                          (index) =>
                                                              DropdownMenuItem(
                                                            child: Text(index
                                                                .toString()),
                                                            value: index,
                                                          ),
                                                        ),
                                                        onChanged: (value) {},
                                                      ),
                                                      Text("16"),
                                                      ElevatedButton(
                                                        onPressed: () {},
                                                        child: Text(
                                                          'Confirmar',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.warehouse))
                            ],
                          ),
                          // CONDUCTOR-CANTIDAD PEDIDOS
                          Row(
                            children: [
                              Text(
                                  "Conductor: ${rutasempleado[index].conductorid}"),
                              const SizedBox(
                                width: 20,
                              ),
                              const Text(
                                "X",
                                style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                          // VEHICULO - EDIT - DELETE
                          Row(
                            children: [
                              Text(
                                  "Vehículo: ${rutasempleado[index].vehiculoid}"),
                              const SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        // llamando a la función
                                        CircularProgressIndicator(
                                          backgroundColor: Colors.deepPurple,
                                        );

                                        //print(rutasempleado[index].id);
                                        await getpedidosruta(
                                            rutasempleado[index].id);

                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.25,
                                                  height: 600,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Editar ruta",
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              25,
                                                          color: Color.fromARGB(
                                                              255, 70, 58, 77),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Columna 1: Inputs y Dropdowns
                                                          const SizedBox(
                                                              width: 20),

                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                2,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            color: const Color
                                                                .fromARGB(255,
                                                                240, 241, 239),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Campo de texto para el nombre de la ruta
                                                                Center(
                                                                  child:
                                                                      Container(
                                                                    child:const Text(
                                                                      "Editar campos",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              57,
                                                                              46,
                                                                              59)),
                                                                    ),
                                                                  ),
                                                                ),
                                                               /* Container(
                                                                  color: Colors
                                                                      .white,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              16),
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        _text1,
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Nombre de ruta',
                                                                    ),
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .text,
                                                                  ),
                                                                ),*/
                                                                // Dropdown para conductores
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      6,
                                                                  color: Colors
                                                                      .white,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              16),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 180,
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment
                                                                                  .start,
                                                                          children: [
                                                                            const Text(
                                                                                "Conductores"),
                                                                            StatefulBuilder(
                                                                              builder: (BuildContext
                                                                                      context,
                                                                                  StateSetter
                                                                                      setState) {
                                                                                return DropdownButton<
                                                                                    Conductor>(
                                                                                  hint:
                                                                                      const Text('Selecciona un conductor',style: TextStyle(
                                                                                        fontSize: 13
                                                                                      ),),
                                                                                  value:
                                                                                      selectedConductor,
                                                                                  items:
                                                                                      conductorget.map((Conductor chofer) {
                                                                                    return DropdownMenuItem<Conductor>(
                                                                                      value: chofer,
                                                                                      child: Text(chofer.nombres),
                                                                                    );
                                                                                  }).toList(),
                                                                                  onChanged:
                                                                                      (Conductor? newValue) {
                                                                                    setState(() {
                                                                                      selectedConductor = newValue;
                                                                                    });
                                                                                  },
                                                                                );
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.yellow,
                                                                          borderRadius: BorderRadius.circular(20)
                                                                        ),
                                                                        
                                                                        child: IconButton(onPressed: (){
                                                                          
                                                                        },
                                                                         icon:const Icon(Icons.update,color: Colors.red,)),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                                    ],
                                                                  ),
                                                                ),
                                                                // Dropdown para vehículos
                                                                Container(
                                                                  color: Colors
                                                                      .white,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      6,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              16),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 180,
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment
                                                                                  .start,
                                                                          children: [
                                                                            const Text(
                                                                                "Vehículos"),
                                                                            StatefulBuilder(
                                                                              builder: (BuildContext
                                                                                      context,
                                                                                  StateSetter
                                                                                      setState) {
                                                                                return DropdownButton<
                                                                                    Vehiculo>(
                                                                                  isExpanded:
                                                                                      true,
                                                                                  hint:
                                                                                      const Text('Selecciona un vehículo',style: TextStyle(
                                                                                        fontSize: 13
                                                                                      ),),
                                                                                  value:
                                                                                      selectedVehiculo,
                                                                                  items:
                                                                                      vehiculos.map((Vehiculo auto) {
                                                                                    return DropdownMenuItem<Vehiculo>(
                                                                                      value: auto,
                                                                                      child: Text(auto.nombre_modelo),
                                                                                    );
                                                                                  }).toList(),
                                                                                  onChanged:
                                                                                      (Vehiculo? newValue) {
                                                                                    setState(() {
                                                                                      selectedVehiculo = newValue;
                                                                                    });
                                                                                  },
                                                                                );
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                     Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.yellow,
                                                                          borderRadius: BorderRadius.circular(20)
                                                                        ),
                                                                        
                                                                        child: IconButton(onPressed: (){},
                                                                         icon:const Icon(Icons.update,color: Colors.red,)),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                                      
                                                                    ],
                                                                  ),
                                                                ),
                                                                
                                                              ],
                                                            ),
                                                          ),

                                                          // Columna 2: Distritos con pedidos
                                                          const SizedBox(
                                                              width: 20),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2.5,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                2,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            color:
                                                                const Color.fromARGB(
                                                                    255,
                                                                    242,
                                                                    222,
                                                                    255),
                                                            child:
                                                                GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .translucent,
                                                              onHorizontalDragUpdate:
                                                                  (details) {
                                                                _scrollController3.jumpTo(_scrollController3
                                                                        .position
                                                                        .pixels +
                                                                    details
                                                                        .primaryDelta!);
                                                              },
                                                              child:
                                                                  SingleChildScrollView(
                                                                controller:
                                                                    _scrollController3,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                  children: List
                                                                      .generate(
                                                                    distrito_de_pedido
                                                                        .length,
                                                                    (index) =>
                                                                        Container(
                                                                      width:
                                                                          250,
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              10),
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      child:
                                                                          Card(
                                                                        elevation:
                                                                            8,
                                                                        color: Colors
                                                                            .white,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              Text(distrito_de_pedido[index]), //distrito_de_pedido[index].nombre),
                                                                              Container(
                                                                                width: 200,
                                                                                height: 200,
                                                                                margin: const EdgeInsets.all(5),
                                                                                child: ListView.builder(
                                                                                  itemCount:distrito_pedido['${distrito_de_pedido[index]}']!.length,
                                                                                  itemBuilder: (BuildContext context, int index2) {
                                                                                    return StatefulBuilder(
                                                                                      builder: (BuildContext context, StateSetter setState) {
                                                                                        return Container(
                                                                                                      margin: const EdgeInsets.all(5),
                                                                                                      color: const Color.fromARGB(255, 153, 218, 222),
                                                                                                      child: CheckboxListTile(
                                                                                                        value: distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado,
                                                                                                        onChanged: (bool? value) {
                                                                                                          setState(() {
                                                                                                            //  print("seleccionando");

                                                                                                            distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado = value!;
                                                                                                            // print(distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado);
                                                                                                            //print(distrito_pedido['${distrito_de_pedido[index]}']?[index2].id);

                                                                                                            idPedidosSeleccionados.add(distrito_pedido['${distrito_de_pedido[index]}']![index2].id);
                                                                                                          });
                                                                                                        },
                                                                                                        title: Text("N° ${distrito_pedido['${distrito_de_pedido[index]}']?[index2].id}"),
                                                                                                        subtitle: Text("${distrito_pedido['${distrito_de_pedido[index]}']?[index2].nombre}"),
                                                                                                      ),
                                                                                                    );
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          // Columna 3: Pedidos con ícono de borrar
                                                          //const SizedBox(height: 30),
                                                          const SizedBox(
                                                              width: 30),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                6,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                2,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            color:
                                                                const Color.fromARGB(
                                                                    255,
                                                                    125,
                                                                    106,
                                                                    124),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Center(
                                                                  child: Text(
                                                                    'Pedidos Ruta',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        10), // Espacio entre el texto y la lista
                                                                Container(
                                                                  //color:Colors.green,
                                                                  height:
                                                                      320.00,
                                                                  child:pedidosruta
                                                                            .length > 0 ? ListView
                                                                      .builder(
                                                                    itemCount:
                                                                        pedidosruta
                                                                            .length,
                                                                    /* distrito_de_pedido
                                                                            .length*/
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      return Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                16),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(30), // Borde redondeado
                                                                          border: Border.all(
                                                                              color: Colors.black,
                                                                              width: 1), // Borde de color
                                                                        ),
                                                                        child:
                                                                            ListTile(
                                                                          title:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Pedido N°:${pedidosruta[index].id}",
                                                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                                              ),
                                                                              Text("Ruta: ${pedidosruta[index].ruta_id}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                              Text("Nombre: ${pedidosruta[index].nombre_cliente}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                              Text("Apellidos: ${pedidosruta[index].apellidos_cliente}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                                   Text(
                                                                                "Telefono:${pedidosruta[index].telefono_cliente}",
                                                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                                              ),
                                                                              Text("Total: ${pedidosruta[index].total}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                              Text("Fecha: ${pedidosruta[index].fecha}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                              Text("Tipo: ${pedidosruta[index].tipo}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                            Text("Distrito: ${pedidosruta[index].distrito}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                              Text("Direccion: ${pedidosruta[index].direccion}",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                            ],
                                                                          ), //Text(distrito_de_pedido[index].nombre),
                                                                          trailing:
                                                                              IconButton(
                                                                            icon:
                                                                                Icon(Icons.delete, color: Color.fromARGB(255, 95, 121, 153)),
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                // Acción de borrado, por ejemplo, remover el distrito
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        title: const Text('¿Estás seguro que deseas revertir o eliminar?'),
                                                                                        //content: const Text('AlertDialog description'),
                                                                                        actions: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              TextButton(
                                                                                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                                                                                child: const Text('Cancelar'),
                                                                                              ),
                                                                                              TextButton(
                                                                                                onPressed: () async{
                                                                                                  await deleterevertir(pedidosruta[index].id);
                                                                                                  if(mensajedelete=='Pedido revertido o eliminado'){
                                                                                                    showDialog(context: context, builder:(BuildContext context){
                                                                                                      return AlertDialog(
                                                                                                        title: Row(
                                                                                                          children: [
                                                                                                            Text(mensajedelete,style:const TextStyle(
                                                                                                              fontWeight: FontWeight.w600
                                                                                                            ),),
                                                                                                            TextButton(onPressed: (){
                                                                                                              Navigator.pop(context);
                                                                                                              Navigator.pop(context);
                                                                                                             // Navigator.pop(context);
                                                                                                              setState(() {
                                                                                                                
                                                                                                              });
                                                                                                            },
                                                                                                             child: const Text("OK",style: TextStyle(color: Color.fromARGB(255, 39, 48, 129)),))
                                                                                                          ],
                                                                                                        ),
                                                                                                      );
                                                                                                    });
                                                                                                  
                                                                                                  }
                                                                                                },
                                                                                                child: const Text('Si'),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        ],
                                                                                      );
                                                                                    });
                                                                                   

                                                                                // distrito_de_pedido.removeAt(index);
                                                                              });
                                                                            },
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ):const Center(
                                                                    child:  Text("No hay pedidos en esta ruta",style: TextStyle(
                                                                      fontWeight: FontWeight.bold
                                                                    ),),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Center(
                                                        child: Row(
                                                          //crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width: 100,
                                                              height: 100,
                                                              //color: Colors.amber,
                                                              child: ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                        Navigator.pop(context);
                                                                        setState(() {
                                                                          idPedidosSeleccionados = [];
                                                                        });

                                                                      },
                                                                      style: ButtonStyle(
                                                                        elevation: WidgetStateProperty.all(5),
                                                                        backgroundColor: WidgetStateProperty.all(Colors.white)
                                                                      ),
                                                                  child:const Text(
                                                                      "Cancelar",style: TextStyle(
                                                                        fontSize: 13
                                                                      ),)),
                                                            ),
                                                            const SizedBox(width: 10,),
                                                            Container(
                                                              width: 100,
                                                              height: 100,
                                                              child: ElevatedButton(
                                                                  onPressed:
                                                                      () async{
                                                                        showDialog(
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return const AlertDialog(
                                                                                            content: Row(
                                                                                              children: [
                                                                                                CircularProgressIndicator(
                                                                                                  backgroundColor: Colors.green,
                                                                                                ),
                                                                                                SizedBox(width: 20),
                                                                                                Text("Cargando..."),
                                                                                              ],
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      );
                                                                        await updatePedidoRuta(rutasempleado[index].id, "en proceso");
                                                                         Navigator.pop(context);
                                                                                      Navigator.pop(context);
                                                                                      setState(() {

                                                                                       
                                                                                      });
                                                                       // print("id pedidos");
                                                                       // print(idPedidosSeleccionados.length);
                                                                       // idPedidosSeleccionados = [];
                                                                      },
                                                                      style: ButtonStyle(
                                                                        elevation: WidgetStateProperty.all(4),
                                                                        backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 61, 44, 130))
                                                                      ),
                                                                  child: const Text(
                                                                      "Confirmar",style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Colors.white),)),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.edit)),
                                  /*IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  padding: EdgeInsets.all(9),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      5,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4.5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Text(
                                                        "¿Estás seguro de quieres eliminar la ruta?",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  "Cancelar")),
                                                          ElevatedButton(
                                                              onPressed: () {},
                                                              child: const Text(
                                                                  "Si"))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.delete))*/
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
                    "No hay rutas hoy",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
        ),
      ],
    );
  }
}
