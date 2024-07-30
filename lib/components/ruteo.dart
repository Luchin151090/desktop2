import 'dart:ffi';

import 'package:desktop2/components/distritos/distritos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VentasEmpleado {
  int? costo_entregados;
  final String pendiente;
  final String proceso;
  final String entregado;
  final String truncado;

  VentasEmpleado(
      {this.costo_entregados,
      required this.pendiente,
      required this.proceso,
      required this.entregado,
      required this.truncado});
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

class Empleadopedido {
  int? idruta;
  final int npedido;
  final String estado;
  final String tipo;
  final String fecha;
  double? total;
  final String nombres;
  final String vehiculo;

  Empleadopedido(
      {this.idruta,
      required this.npedido,
      required this.estado,
      required this.tipo,
      required this.fecha,
      required this.total,
      required this.nombres,
      required this.vehiculo});
}

// AGENDADOS
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

// PREGUNTAR SI DEBO MODIFICAR EL MODEL CONDUCTOR AÑADIENDO UN ATRIBUTO
// ESTADO  O EN EL LOGIN PARA VER SI SE CONECTO EN TIEMPO REAL
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

class Ruteo extends StatefulWidget {
  const Ruteo({Key? key}) : super(key: key);

  @override
  State<Ruteo> createState() => _RuteoState();
}

class _RuteoState extends State<Ruteo> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
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

  //
  late DateTime fechaparseadas;
  late DateTime fechaHoyruta;
  DateTime now = DateTime.now();
  //LISTAS Y VARIABLES
  List<Pedido> pedidosget = [];
  List<Pedido> pedidoSeleccionado = [];
  Color sinSeleccionar = Colors.green;
  List<LatLng> seleccionadosUbicaciones = [];
  List<Conductor> obtenerConductor = [];
  List<Vehiculo> obtenerVehiculo = [];
  VentasEmpleado? ventasempleado;
  int conductorid = 0;
  int vehiculoid = 0;

  List<LatLng> puntosget = [];
  List<LatLng> puntosnormal = [];
  List<LatLng> puntosexpress = [];

  List<Pedido> hoypedidos = [];
  List<Pedido> hoyexpress = [];
  List<Pedido> agendados = [];
  List<Marker> marcadores = [];

  ///////
  ///
  ///
  ///
  ///
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
  List<Conductor>conductorget = [];
 late Color colormarcador;
 int idConductor = 0;
 int idVehiculo = 0;
 int rutaIdLast = 0;
  List<int>idPedidosSeleccionados =[];
 
 Future<dynamic> createRuta(
      empleado_id, conductor_id, vehiculo_id, distancia, tiempo) async {
    try {
      //    print("Create ruta....");
      //print("conductor ID");
      //print(conductor_id);
      //print("vehiculo_id");
      //print(vehiculo_id);

      
        DateTime now = DateTime.now();

      String formateDateTime = now.toString();
      await http.post(Uri.parse(api + apiRutaCrear),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "conductor_id": conductor_id,
            "vehiculo_id": vehiculo_id,
            "empleado_id": empleado_id,
            "distancia_km": 0,
            "tiempo_ruta": 0,
            "fecha_creacion": formateDateTime
          }));
      // print("Ruta creada");
    } catch (e) {
      throw Exception("$e");
    }
  }
  // LAST RUTA BY EMPRLEADOID
  Future<dynamic> lastRutaEmpleado(empleadoId) async {
    var res = await http.get(
        Uri.parse(api + apiLastRuta + '/' + empleadoId.toString()),
        headers: {"Content-type": "application/json"});

    setState(() {
      rutaIdLast = json.decode(res.body)['id'] ?? 0;
    });
    //print("LAST RUTA EMPLEAD");
    //print(rutaIdLast);
  }

  // UPDATE PEDIDO-RUTA
  Future<dynamic> updatePedidoRuta(ruta_id, estado) async {
    for (var i = 0; i < idPedidosSeleccionados.length; i++) {
      await http.put(
          Uri.parse(
              api + apiUpdateRuta + '/' + idPedidosSeleccionados[i].toString()),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"ruta_id": ruta_id, "estado": estado}));
    }
    // print("RUTA ACTUALIZADA A ");
    // print(ruta_id);

    //ALMACENO LA RUTA EN EL PROVIDER PARA ESE CONDUCTOR
   // Provider.of<RutaProvider>(context, listen: false).updateUser(ruta_id);
  }

  // CREAR Y OBTENER
  Future<void> crearobtenerYactualizarRuta(
      empleadoId, conductorid, vehiculoid, distancia, tiempo, estado) async {
    await createRuta(empleadoId, conductorid, vehiculoid, distancia, tiempo);
    await lastRutaEmpleado(empleadoId);
    await updatePedidoRuta(rutaIdLast, estado);
    //socket.emit('Termine de Updatear', 'si');
  }

  Future<dynamic> getConductores() async {
    try {
      SharedPreferences empleadoShare = await SharedPreferences.getInstance();
      var empleadoIDs = 1;//empleadoShare.getInt('empleadoID');
      print("El empleado traido es");
      print(empleadoIDs);
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
        setState(() {
          conductorget = tempConductor;
        });
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
        setState(() {
          vehiculos = tempVehiculo;
        });
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  Future<dynamic> getPedidos() async {
    try {
      print("---------dentro ..........................get pdeidos");
      print(apipedidos);
      SharedPreferences empleadoShare = await SharedPreferences.getInstance();

      var empleadoIDs = 1; //empleadoShare.getInt('empleadoID');
      var res = await http.get(
          Uri.parse(api + apipedidos + '/' + empleadoIDs.toString()),
          headers: {"Content-type": "application/json"});
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Pedido> tempPedido = data.map<Pedido>((data) {
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

        
        setState(() {
          pedidosget = tempPedido;
          print("---pedidos get");
        print(pedidosget.length);


          // TRAIGO LOS DISTRITOS DE LOS PEDIDOS DE AYER - SOLO LOS DE AYER

          for (var j = 0; j < pedidosget.length; j++) {
            fechaparseadas = DateTime.parse(pedidosget[j].fecha.toString());
            if (pedidosget[j].estado == 'pendiente') {
              if (pedidosget[j].tipo == 'normal'|| pedidosget[j].tipo=='express') {
                if (fechaparseadas.day != now.day) {
                  setState(() {
                    distritosSet.add(pedidosget[j].distrito.toString());
                  });
                }
              }
            }
          }

          // Si necesitas convertirlo a una lista más adelante
          setState(() {
            distrito_de_pedido = distritosSet.toList();
          });
          print("distritos");
          print(distrito_de_pedido);

          // AHORA ITERO  EN TODOS LOS PEDIDOS Y LO RELACIONO SOLO CON LOS DISTRTOS QUE OBTUVE
          for (var x = 0; x < distrito_de_pedido.length; x++) {
            print(distrito_de_pedido[x]);
            for (var j = 0; j < pedidosget.length; j++) {
              fechaparseadas = DateTime.parse(pedidosget[j].fecha.toString());
              if (pedidosget[j].estado == 'pendiente') {

                if (pedidosget[j].tipo == 'normal' || pedidosget[j].tipo=='express') {
                  print("----------TIPO");
                  print(pedidosget[j].tipo);
                  if (fechaparseadas.day != now.day) {
                    if (distrito_de_pedido[x] == pedidosget[j].distrito) { 
                      nuevopedidodistrito.add(pedidosget[j]);
                      print("nuevo pedido distrito ID:");
                      print(pedidosget[j].id);
                      print(pedidosget[j].distrito);
                      print(pedidosget[j].nombre);
                      print(pedidosget[j].apellidos);
                      print(pedidosget[j].tipo);
                      print(pedidosget[j].total);
                    }
                  }
                }
              }

            }
            //SALGO DEL 2DO FOR, PORQUE YA AÑADI SOLO LOS PEDIDOS DE UN DISTRITO EN ESPECIFICO
            // FINALMENTE ESA SERIA LA CLAVE Y EL CONJUNTO DE PEDIDOS DE ESE DISTRITO
            setState(() {
              distrito_pedido['${distrito_de_pedido[x]}'] = nuevopedidodistrito;
              nuevopedidodistrito =
                  []; // SI YA TERMINE DE AÑADIR AL MAP, AHORA SOLO LIMPIO
            });
            print("tamaño de mapa");
            print(distrito_pedido['${distrito_de_pedido[x]}']?.length);
          }

          int count = 1;
          for (var i = 0; i < pedidosget.length; i++) {
            fechaparseadas = DateTime.parse(pedidosget[i].fecha.toString());
            if (pedidosget[i].estado == 'pendiente') {
              // print("pendi...");
              if (pedidosget[i].tipo == 'normal'||pedidosget[i].tipo=='express') {
                // print("normlllll");
                // SI ES NORMAL
                if (fechaparseadas.day != now.day) {
                  // print("no es hoy");
                  // print(fechaparseadas.day);

                  setState(() {
                    LatLng coordGET = LatLng(
                        (pedidosget[i].latitud ?? 0.0) + (0.000001 * count),
                        (pedidosget[i].longitud ?? 0.0) + (0.000001 * count));

                    puntosget.add(coordGET);
                    pedidosget[i].latitud = coordGET.latitude;
                    pedidosget[i].longitud = coordGET.longitude;

                    // print("--get posss");
                    // print(coordGET);
                    agendados.add(pedidosget[i]);
                    print("......AGENDADOS");
                    print(agendados);
                  });
                }
              } 
            } else {
              setState(() {});
            }
            count++;
          }
        });

        // OBTENER COORDENADAS DE LOS PEDIDOS
        // for (var i = 0; i < pedidosget.length; i++) {}
        //print("PUNTOS GET");
        //print(puntosget);

        // PONER MARCADOR PARA AGENDADOS
        marcadoresPut("agendados");
        setState(() {});

        setState(() {
          number = agendados.length;
        });
        print("ageng tama");
        print(number);
      }
    } catch (e) {
      throw Exception('Error $e');
    }
  }

  void marcadoresPut(tipo) {
    setState(() {
      
    });
    if (tipo == 'agendados') {
      
      int count = 1;

      final Map<LatLng, Pedido> mapaLatPedido = {};

      for (var i = 0; i < puntosget.length; i++) {
        //print("---||||||||||||||||||||---");
        //print(puntosget[i].latitude);
        //print(puntosget[i].longitude);
        double offset = count * 0.000001;
        LatLng coordenada = puntosget[i];
        Pedido pedido = agendados[i];

        mapaLatPedido[LatLng(coordenada.latitude, coordenada.longitude)] =
            pedido;

        setState(() {
          marcadores.add(
            Marker(
              point: LatLng(
                  coordenada.latitude + offset, coordenada.longitude + offset),
              width: 140,
              height: 150,
              child: GestureDetector(
                onTap: () {
                  print("dentro-------------------------");
                  setState(() {
                    print(mapaLatPedido[
                            LatLng(coordenada.latitude, coordenada.longitude)]
                        ?.estado);
                    mapaLatPedido[
                            LatLng(coordenada.latitude, coordenada.longitude)]
                        ?.estado = 'en proceso';
                    print("------estadito");

                    Pedido? pedidoencontrado = mapaLatPedido[
                        LatLng(coordenada.latitude, coordenada.longitude)];
                    pedidoSeleccionado.add(pedidoencontrado!);
                  });
                },
                child: Container(
                    height: 155,
                    width: 140,
                    //color: Colors.grey,
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white.withOpacity(0.5),
                              border: Border.all(
                                  width: 1,
                                  color:
                                      const Color.fromARGB(255, 10, 72, 123))),
                          child: Center(
                              child: Text(
                            "${pedido.id}",
                            style: const TextStyle(
                                fontSize: 19,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          )),
                        ),
                        Container(
                          //margin: const EdgeInsets.only(right: 20),
                          width: 94,
                          height: 94,
                          // color:Colors.blueGrey,
                          decoration: BoxDecoration(
                              // color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                  image:
                                      AssetImage('lib/imagenes/pinblue.png'))),
                        ),
                      ],
                    ) /*Icon(Icons.location_on_outlined,
              size: 40,color: Colors.blueAccent,)*/
                    ),
              ),
            ),
          );
        });
        count++;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getPedidos();
    getVehiculos();
    getConductores();
  }

  final ScrollController _scrollController2 = ScrollController();

  @override
  void dispose() {
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Container(
          padding: EdgeInsets.all(19),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              // ITEMS
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Agendados",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(255, 231, 231, 231)),
                        width: MediaQuery.of(context).size.width / 8,
                        height: MediaQuery.of(context).size.height/1.1,
                        child: number > 0
                            ? ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: number, // cantidad de pedidos
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: 200,
                                    margin: EdgeInsets.all(5),
                                    color: Color.fromARGB(255, 174, 151, 179),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Center(
                                            child: Text(
                                          'Pedido N: ${agendados[index].id} ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        Text(
                                            "Estado: ${agendados[index].estado}"),
                                        Text(
                                            "Fecha: ${agendados[index].fecha}"),
                                        Text(
                                            "Total:S/.${agendados[index].total}"),
                                        Text(
                                            "Nombres: ${agendados[index].nombre}"),
                                        Text(
                                            "Apellidos: ${agendados[index].apellidos}"),
                                        Text(
                                            "Distrito:${agendados[index].distrito}")
                                      ],
                                    ),
                                  );
                                })
                            : Container(
                                child: const Center(
                                    child: Text(
                                  "No hay pedidos agendados.\n Espera al próximo día.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )),
                              ),
                      ),
                    ],
                  ),
                 
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              // TIEMPO REAL
              Column(
                children: [
                  Text("Tiempo Real"),
                  Container(
                    color: Colors.grey,
                    height: MediaQuery.of(context).size.height / 1.08,
                    width: 300,
                    child: ListView.builder(
                        itemCount: 900,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            margin: EdgeInsets.all(10),
                            child: Text("Pedido X :"),
                          );
                        }),
                  )
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              //MAPA
              Column(
                children: [
                  Text("Mapa de pedidos"),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        //color: Color.fromARGB(255, 198, 172, 181),
                        borderRadius: BorderRadius.circular(20)),
                    width: MediaQuery.of(context).size.width / 2.2,
                    height: MediaQuery.of(context).size.height / 1.1,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(-16.4055657, -71.5719081),
                            initialZoom: 14.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                ...marcadores,
                                //...expressmarker,
                                // ...normalmarker,
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                            top: 10,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                  //color: Colors.blue,
                                  ),
                              child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        barrierColor: const Color.fromARGB(
                                                255, 241, 204, 204)
                                            .withOpacity(0.35),
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor: Color.fromARGB(255, 205, 190, 216),
                                            surfaceTintColor:
                                                Color.fromARGB(255, 219, 212, 227),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              padding: EdgeInsets.all(15),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.2,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Center(
                                                      child: Text(
                                                    "Crea tu ruta",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                  const SizedBox(
                                                    height: 50,
                                                  ),

                                                  // DROPS MENUS GENERICOS
                                                  // LIST VIEW DE PEDIDOS DISTRITOS
                                                  Container(
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // DROPS
                                                        Container(
                                                          width: MediaQuery.of(context).size.width/6,
                                                          height: MediaQuery.of(context).size.height/2,
                                                          padding: EdgeInsets.all(10),
                                                          color: const Color.fromARGB(255, 250, 203, 219),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              
                                                              Container(
                                                                color: Colors.white,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
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
                                                                          .number,
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(context).size.width/6,
                                                                color: Colors.white,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        "Conductores"),
                                                                    StatefulBuilder(builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                                      return DropdownButton(
                                                                        hint: const Text(
                                                                            'Conductores'),
                                                                        value:
                                                                            selectedConductor,
                                                                        items: conductorget.map((Conductor
                                                                            chofer) {
                                                                          return DropdownMenuItem<
                                                                              Conductor>(
                                                                            value:
                                                                                chofer,
                                                                            child:
                                                                                Text("${chofer.nombres}"),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (Conductor?
                                                                                newValue) {
                                                                          setState(
                                                                              () {
                                                                            selectedConductor =
                                                                                newValue;
                                                                          });
                                                                        },
                                                                      );
                                                                    }),
                                                                  ],
                                                                ),
                                                              ),
                                                              // VEHICULOS-----------
                                                              Container(
                                                                color: Colors.white,
                                                                width: MediaQuery.of(context).size.width/6,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        "Vehículos"),
                                                                    StatefulBuilder(builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                                      return DropdownButton(
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
                                                                      );
                                                                    }),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 20,),
                                                        //LISTVIEW
                                                        Container(
        width: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.height / 2.5,
        padding: const EdgeInsets.all(10),
        color: Color.fromARGB(255, 242, 222, 255),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            _scrollController2.jumpTo(
                _scrollController2.position.pixels + details.primaryDelta!);
          },
          child: SingleChildScrollView(
            controller: _scrollController2,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                distrito_de_pedido.length,
                (index) => Container(
                  width: 250,
                  
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    elevation: 8,
                    borderOnForeground: true,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // NOMBRE DEL DISTRITO DINAMICO
                          Text(distrito_de_pedido[index]),
                          Container(
                            width: 200,
                            height: 200,
                            //color: Colors.blue,
                            margin: EdgeInsets.all(5),
                            child: ListView.builder(
                              itemCount:distrito_pedido['${distrito_de_pedido[index]}']!.length ,
                              itemBuilder: (BuildContext context,int index2){
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                    StateSetter setState){return Container(
                                      margin: EdgeInsets.all(5),
                                      color: Color.fromARGB(255, 153, 218, 222),
                                      child: CheckboxListTile(
                                                value: distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    print("seleccionando");
                                                    
                                                    distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado = value!;
                                                    print(distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado);
                                                    print(distrito_pedido['${distrito_de_pedido[index]}']?[index2].id);
                                                   
                                                   
                                                    idPedidosSeleccionados.add(distrito_pedido['${distrito_de_pedido[index]}']![index2].id);
                                                  });
                                                  
                                                },
                                                title: Text("N° ${distrito_pedido['${distrito_de_pedido[index]}']?[index2].id}"),
                                                subtitle: Text("${distrito_pedido['${distrito_de_pedido[index]}']?[index2].nombre}"),
                                              ),
                                    );}
                                );
                              },
                            ), /*Column(
                              children: 
                                List.generate(distrito_pedido['${distrito_de_pedido[index]}']!.length, (index2)=>Container(
                                  child: Column(
                                    children: [
                                      
                                      Text("${distrito_pedido['${distrito_de_pedido[index]}']?[index2].nombre}")
                                    ],
                                  ),
                                )),
                              
                            )*/
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
                                                        const SizedBox(width: 20,),

                                                        // MAPA DIALOGO
                                                        Container(
                                                          width: MediaQuery.of(context).size.width/3.5,
                                                          height: MediaQuery.of(context).size.height/1.72,
                                                          padding: EdgeInsets.all(10),
                                                          color: Color.fromARGB(255, 190, 230, 221),
                                                         // color: Colors.pink,
                                                          child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(-16.4055657, -71.5719081),
                            initialZoom: 10.85,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                ...marcadores,
                                //...expressmarker,
                                // ...normalmarker,
                              ],
                            ),
                          ],
                        ),
                                                        )

                                                      ],
                                                    ),
                                                  ),
                                                  /*Container(
                                                    height: 100*2,
                                                    child: ListView.builder(
                                                      itemCount: distrito_de_pedido.length,
                                                      itemBuilder: (BuildContext context,int index){
                                                      return Container(
                                                        
                                                        child: Column(children: [
                                                          Text("Distrito:${distrito_de_pedido[index]}"),
                                                         Container(
                                                            height: 50,
                                                            child: ListView.builder(
                                                              itemCount:distrito_pedido['${distrito_de_pedido[index]}']?.length,
                                                              itemBuilder: (BuildContext context,int index2){
                                                                return Text("${distrito_pedido['${distrito_de_pedido[index]}']?[index2].apellidos}");
                                                            }),
                                                          ),
                                                          DropdownButton<String>(
            hint: const Text('Select a color'),
            value: selectedColor,
            items: colors.map((String color) {
              return DropdownMenuItem<String>(
                value: color,
                child: Text(color),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedColor = newValue;
              });
            },
          )

                                                        ],),
                                                      );
                                                    }),
                                                  ),*/
                                                  const SizedBox(
                                                    height: 49,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Center(
                                                        child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text("Cerrar")),
                                                      ),
                                                      Container(
                                                        
                                                        child: ElevatedButton(onPressed: ()async{
                                                          print("iid.........s");
                                                          print(selectedConductor!.id);
                                                          print(selectedVehiculo!.id);
                                                          await crearobtenerYactualizarRuta(1, selectedConductor!.id, selectedVehiculo!.id, 0, 0,'en proceso');

                                                          print("holiiiii");
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: WidgetStateProperty.all(Colors.purple)
                                                        ),
                                                         child: Text(" Crear Ruta",style: TextStyle(color: Colors.white),)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  style: ButtonStyle(
                                      elevation: WidgetStateProperty.all(20),
                                      backgroundColor: WidgetStateProperty.all(
                                          Color.fromARGB(255, 103, 84, 175))),
                                  child: Text(
                                    "Crear ruta",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  )),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
              // RUTAS CREADAS
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 109, 157),
                            borderRadius: BorderRadius.circular(20)),
                        child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.visibility_outlined,
                            )),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        "Rutas Creadas",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      //color: Color.fromARGB(255, 206, 161, 195)
                    ),
                    width: MediaQuery.of(context).size.width / 8,
                    height: MediaQuery.of(context).size.height / 1.12,
                    child: 2 > 0
                        ? ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: 8,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 150,
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color.fromARGB(255, 214, 214, 214),
                                ),
                                child: Center(
                                    child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('Ruta Pato'),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.visibility)),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.warehouse))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text("Conductor: $index"),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
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
                                                onPressed: () {
                                    showDialog(
                                        context: context,
                                        barrierColor: const Color.fromARGB(
                                                255, 241, 204, 204)
                                            .withOpacity(0.35),
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor: Color.fromARGB(255, 205, 190, 216),
                                            surfaceTintColor:
                                                Color.fromARGB(255, 219, 212, 227),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              padding: EdgeInsets.all(15),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.2,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Center(
                                                      child: Text(
                                                    "Crea tu ruta",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                  const SizedBox(
                                                    height: 50,
                                                  ),

                                                  // DROPS MENUS GENERICOS
                                                  // LIST VIEW DE PEDIDOS DISTRITOS
                                                  Container(
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // DROPS
                                                        Container(
                                                          width: MediaQuery.of(context).size.width/6,
                                                          height: MediaQuery.of(context).size.height/2,
                                                          padding: EdgeInsets.all(10),
                                                          color: const Color.fromARGB(255, 250, 203, 219),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              
                                                              Container(
                                                                color: Colors.white,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
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
                                                                          .number,
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(context).size.width/6,
                                                                color: Colors.white,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        "Conductores"),
                                                                    StatefulBuilder(builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                                      return DropdownButton(
                                                                        hint: const Text(
                                                                            'Conductores'),
                                                                        value:
                                                                            selectedConductor,
                                                                        items: conductorget.map((Conductor
                                                                            chofer) {
                                                                          return DropdownMenuItem<
                                                                              Conductor>(
                                                                            value:
                                                                                chofer,
                                                                            child:
                                                                                Text("${chofer.nombres}"),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (Conductor?
                                                                                newValue) {
                                                                          setState(
                                                                              () {
                                                                            selectedConductor =
                                                                                newValue;
                                                                          });
                                                                        },
                                                                      );
                                                                    }),
                                                                  ],
                                                                ),
                                                              ),
                                                              // VEHICULOS-----------
                                                              Container(
                                                                color: Colors.white,
                                                                width: MediaQuery.of(context).size.width/6,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        "Vehículos"),
                                                                    StatefulBuilder(builder: (BuildContext
                                                                            context,
                                                                        StateSetter
                                                                            setState) {
                                                                      return DropdownButton(
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
                                                                      );
                                                                    }),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 20,),
                                                        //LISTVIEW
                                                        Container(
        width: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.height / 2.5,
        padding: const EdgeInsets.all(10),
        color: Color.fromARGB(255, 242, 222, 255),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            _scrollController2.jumpTo(
                _scrollController2.position.pixels + details.primaryDelta!);
          },
          child: SingleChildScrollView(
            controller: _scrollController2,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                distrito_de_pedido.length,
                (index) => Container(
                  width: 250,
                  
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    elevation: 8,
                    borderOnForeground: true,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // NOMBRE DEL DISTRITO DINAMICO
                          Text(distrito_de_pedido[index]),
                          Container(
                            width: 200,
                            height: 200,
                            //color: Colors.blue,
                            margin: EdgeInsets.all(5),
                            child: ListView.builder(
                              itemCount:distrito_pedido['${distrito_de_pedido[index]}']!.length ,
                              itemBuilder: (BuildContext context,int index2){
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                    StateSetter setState){return Container(
                                      margin: EdgeInsets.all(5),
                                      color: Color.fromARGB(255, 153, 218, 222),
                                      child: CheckboxListTile(
                                                value: distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    print("seleccionando");
                                                    
                                                    distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado = value!;
                                                    print(distrito_pedido['${distrito_de_pedido[index]}']?[index2].seleccionado);
                                                    print(distrito_pedido['${distrito_de_pedido[index]}']?[index2].id);
                                                   
                                                   
                                                    idPedidosSeleccionados.add(distrito_pedido['${distrito_de_pedido[index]}']![index2].id);
                                                  });
                                                  
                                                },
                                                title: Text("N° ${distrito_pedido['${distrito_de_pedido[index]}']?[index2].id}"),
                                                subtitle: Text("${distrito_pedido['${distrito_de_pedido[index]}']?[index2].nombre}"),
                                              ),
                                    );}
                                );
                              },
                            ), /*Column(
                              children: 
                                List.generate(distrito_pedido['${distrito_de_pedido[index]}']!.length, (index2)=>Container(
                                  child: Column(
                                    children: [
                                      
                                      Text("${distrito_pedido['${distrito_de_pedido[index]}']?[index2].nombre}")
                                    ],
                                  ),
                                )),
                              
                            )*/
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
                                                        const SizedBox(width: 20,),

                                                        // MAPA DIALOGO
                                                        Container(
                                                          width: MediaQuery.of(context).size.width/3.5,
                                                          height: MediaQuery.of(context).size.height/1.72,
                                                          padding: EdgeInsets.all(10),
                                                          color: Color.fromARGB(255, 190, 230, 221),
                                                         // color: Colors.pink,
                                                          child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(-16.4055657, -71.5719081),
                            initialZoom: 10.85,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                ...marcadores,
                                //...expressmarker,
                                // ...normalmarker,
                              ],
                            ),
                          ],
                        ),
                                                        )

                                                      ],
                                                    ),
                                                  ),
                                                  /*Container(
                                                    height: 100*2,
                                                    child: ListView.builder(
                                                      itemCount: distrito_de_pedido.length,
                                                      itemBuilder: (BuildContext context,int index){
                                                      return Container(
                                                        
                                                        child: Column(children: [
                                                          Text("Distrito:${distrito_de_pedido[index]}"),
                                                         Container(
                                                            height: 50,
                                                            child: ListView.builder(
                                                              itemCount:distrito_pedido['${distrito_de_pedido[index]}']?.length,
                                                              itemBuilder: (BuildContext context,int index2){
                                                                return Text("${distrito_pedido['${distrito_de_pedido[index]}']?[index2].apellidos}");
                                                            }),
                                                          ),
                                                          DropdownButton<String>(
            hint: const Text('Select a color'),
            value: selectedColor,
            items: colors.map((String color) {
              return DropdownMenuItem<String>(
                value: color,
                child: Text(color),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedColor = newValue;
              });
            },
          )

                                                        ],),
                                                      );
                                                    }),
                                                  ),*/
                                                  const SizedBox(
                                                    height: 49,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Center(
                                                        child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text("Cerrar")),
                                                      ),
                                                      Container(
                                                        
                                                        child: ElevatedButton(onPressed: ()async{
                                                          print("iid.........s");
                                                          print(selectedConductor!.id);
                                                          print(selectedVehiculo!.id);
                                                          await crearobtenerYactualizarRuta(1, selectedConductor!.id, selectedVehiculo!.id, 0, 0,'en proceso');

                                                          print("holiiiii");
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: WidgetStateProperty.all(Colors.purple)
                                                        ),
                                                         child: Text("Actualizar ruta",style: TextStyle(color: Colors.white),)),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                                icon: Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.delete))
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                )),
                              );
                            })
                        : Container(
                            child: Center(
                                child: Text(
                              "No hay rutas chiveras.",
                              textAlign: TextAlign.center,
                            )),
                          ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
