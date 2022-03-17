// ignore_for_file: avoid_print
//USO DE TERNARIO

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //Lista de Tipo <Band> llamada bands (aqui se hace el autoimport de band.dart), y lo rellenamos con informacion
  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 2),
    // Band(id: '2', name: 'Héroes Del Silencio', votes: 3),
    // Band(id: '3', name: 'Foo Fighters', votes: 1),
    // Band(id: '4', name: 'Aterciopelados', votes: 5),
  ];

  //se agrega para escuchar el evento 'active-bands' en initState
  @override
  void initState() {
    
    final socketService = Provider.of<SocketService>(context,listen: false); //no necesita redibujar nada si cambia

    socketService.socket.on('active-bands', _handleActiveBands );

    super.initState();
  }

  _handleActiveBands( dynamic payload ) {

    this.bands = (payload as List)
      .map( (band) => Band.fromMap(band))
      .toList();

      setState(() { });

  }


  //dejar de escuchar el evento, no se va a llamar
  @override
  void dispose() {
    
    final socketService = Provider.of<SocketService>(context,listen: false); //no necesita redibujar nada si cambia

    socketService.socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //Tarea Referencia al SocketService para indicador de conexion
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        //Indicador de conexion 
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            //TERNARIO
            child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.check_circle, color: Colors.blue[300])
              : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
        ),
      body: Column(
        children: <Widget>[

          //metodo que regresara el Widget de la grafica
          _showGraph(),

          //Se envuelve en Expaned al incluirlo en la columna
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) {
                return _bandTile(bands[index]); //extraemos widget ListTile a metodo a _bandTile //caambiamos index por band[index] error index no es de tipo band
              },
            ),
          ) 
        ],
      ),

      //o este codigo

      // ListView.builder(
      //   itemCount: bands.length,
      //   itemBuilder: ( context , i) => return _bandTile( bands [i] )
      //   
      // )


      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBandDialog,
      ),
   );
  }


  //tarjeta individual de Bandas
  
  Widget _bandTile(Band band) { //cambiamos int index por Band band //cambiamos el ListTile por Widget
    
    final socketService = Provider.of<SocketService>(context,listen: false);
    
    return Dismissible(//Envolvemos ListTile con Dismissible y agregamos el unico key: band.id
      key: Key(band.id!),
      //limitar la direccion
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) {
        // ignore: 
        // print('direction: $direction');
        // print('id: ${band.id}');
        //AQUI Llamar metodo para borrar de la lista / servidor
        socketService.socket.emit('delete-band',{ 'id' : band.id });




      }, // . ---- > lo que se vera cuando arrastre para borrar
      background: Container(
        padding: const EdgeInsets.only( left: 10 ),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          //FALTA agregar icono con bote de basura
          child: Text('Delete Band',style: TextStyle( color: Colors.white ),),
      ) , //puede recibir un wodget que estara atras del dismissible
        ),
      child: ListTile( 
            leading: CircleAvatar( //circulo de icono
              child: Text(band.name!.substring(0,2)), //primeras dos letras del nombre de las banda, // cambiamos  bands[index] por band
              backgroundColor: Colors.blue[100],
            ),
            title: Text(band.name!),
            trailing: Text(
              '${band.votes}',
              style: const TextStyle(fontSize: 20),
            ),
            onTap: () {
              //AQUI se llamara metodo para sumar una banda
              //evento emitido en Flutter
              socketService.socket.emit('vote-band', { 'id': band.id });
              // print(band.name);
              // print(band.id);
            },
      ),
    ); 
  }

  //Dentro del state

  //metodo para agregar nueva Band
  addNewBandDialog(){

    //para obtener la informacion del TextField y poderla guardar en la lista necesitamos definir un TextEditingController
    final textController = TextEditingController() ;

    //validacion para Plataforma
    if (Platform.isAndroid){
        showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            title: const Text("New Band Name"),
            content: TextField(
            //despues de definir el textController se lo asignamos a este Texfield
            controller: textController,

            ),
          //dentro del alert dialog van las actions
            actions: <Widget> [
              MaterialButton(
                child: const Text('Add'),
                textColor: Colors.blue,
                elevation: 5,
                onPressed: (){
                  //print(textController.text);
                  //Metodo para agregar a lista/servidor en Android

                  // socketService.socket.emit('afdd-band',{'bandName':textController.text});

                  addBandToList(textController.text);

                },
              )
            ],
          );
        },
      );
    } else if ( Platform.isMacOS ){ //Necesita el boton de Cancelar
      showCupertinoDialog(
        context: context, 
        builder: ( _ ){ //No vamos a usar el context por eso se pone un _
          return CupertinoAlertDialog(
            title: const Text('New Band Name'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [ //en ios tiene un widget diferente
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Add'),
                onPressed: () {
                  //Metodo para agregar a lista/servidor en iOS
                  addBandToList(textController.text);
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )

            ],
          );
        }
      );
    }
  }


  //para difereciar entre ios y andriod lo llamaremos de dos formas

  void addBandToList(String name){

    final socketService = Provider.of<SocketService>(context, listen: false);

    // print(name);

    //validacion para saber el campo name no esta vacio
    if(name.length > 1){

      // //antigua manera de agregar a la lista local
      // //podemos agregar
      // //creamnos una nueva instancia de Band llamada name y lo agregamos a la lista y que la actualice
      // // this.bands.add
      // bands.add(
      //   Band(
      //     id: DateTime.now().toString(),
      //     name: name,
      //     votes: 0

      //   )
      // );
      // //para actualizar y lo metemos al .add
      // // setState(() {  });

      //emitir evento para agregar banda
      socketService.socket.emit('add-band',{ 'name' : name });



    }
    //UNa vez hecho el add tenemos que cerrar el Dialog
    Navigator.pop(context);

  }

  //mostrar grafica, agregamos Widget
  Widget _showGraph() {

    //Antigua Liata de Datos
    // Map<String, double> dataMap = {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };

    Map<String, double> dataMap = new Map();

    //llenado de dataMap con los elementos de bands
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble());
    });

    //colorlist requerido por PieChart, definido por nosotros
    final List<Color> colorList = [
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.orange,
    ];

    return dataMap.isNotEmpty ? Container(
      padding: EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "BANDS",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          // legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      )
    )
    : LinearProgressIndicator();
    

  }



}