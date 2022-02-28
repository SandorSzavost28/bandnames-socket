import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //Lista de Tipo <Band> llamada bands (aqui se hace el autoimport de band.dart), y lo rellenamos con informacion
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 2),
    Band(id: '2', name: 'Héroes Del Silencio', votes: 3),
    Band(id: '3', name: 'Foo Fighters', votes: 1),
    Band(id: '4', name: 'Aterciopelados', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) {
          return _bandTile(bands[index]); //extraemos widget ListTile a metodo a _bandTile //caambiamos index por band[index] error index no es de tipo band
        },
      ),

      //o este codigo

      // ListView.builder(
      //   itemCount: bands.length,
      //   itemBuilder: ( context , i) => return _bandTile( bands [i] )
      //   
      // )


      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBandDialog,
      ),
   );
  }


  //tarjeta individual de Bandas
  
  Widget _bandTile(Band band) { //cambiamos int index por Band band //cambiamos el ListTile por Widget
    return Dismissible(//Envolvemos ListTile con Dismissible y agregamos el unico key: band.id
      key: Key(band.id!),
      //limitar la direccion
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: ${direction}');
        print('id: ${band.id}');
        //TODO: Llamar metodo para borrar de la lista / servidor

      }, // . ---- >
      background: Container(
        padding: EdgeInsets.only( left: 10 ),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          //TODO: agregar icono con bote de basura
          child: Text('Delete Band',style: TextStyle( color: Colors.white ),),
        ),
      ) , //puede recibir un wodget que estara atras del dismissible
      child: ListTile( 
            leading: CircleAvatar( //circulo de icono
              child: Text(band.name!.substring(0,2)), //primeras dos letras del nombre de las banda, // cambiamos  bands[index] por band
              backgroundColor: Colors.blue[100],
            ),
            title: Text(band.name!),
            trailing: Text(
              '${band.votes}',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              print(band.name);
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
            title: Text("New Band Name"),
            content: TextField(
            //despues de definir el textController se lo asignamos a este Texfield
            controller: textController,

            ),
          //dentro del alert dialog van las actions
            actions: <Widget> [
              MaterialButton(
                child: Text('Add'),
                textColor: Colors.blue,
                elevation: 5,
                onPressed: (){
                  //print(textController.text);
                  //Metodo para agregar a lista/servidor en Android
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
            title: Text('New Band Name'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [ //en ios tiene un widget diferente
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () {
                  //Metodo para agregar a lista/servidor en iOS
                  addBandToList(textController.text);
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Cancel'),
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

    print(name);

    //validacion para saber el campo name no esta vacio
    if(name.length > 1){
      //podemos agregar

      //creamnos una nueva instancia de Band llamada name y lo agregamos a la lista y que la actualice
      this.bands.add(
        Band(
          id: DateTime.now().toString(),
          name: name,
          votes: 0

        )
      );
      //para actualizar y lo metemos al .add
      setState(() {  });

    }
    //UNa vez hecho el add tenemos que cerrar el Dialog
    Navigator.pop(context);

  }



}