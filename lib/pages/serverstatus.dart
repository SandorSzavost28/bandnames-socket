import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';


class ServerStatusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    // socketService.socket.emit(event);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Server Status: ${ socketService.serverStatus }'),
          ],
        )
     ),
     floatingActionButton: FloatingActionButton(
       child: Icon(Icons.message),
       onPressed: (){
         //TAREA
        socketService.emit( //quitamos el .socket.emit gracias a la simplificacion de codigo
          'emitir-mensaje', 
          { 'nombre':'Flutter' , 'mensaje':'Hola desde Flutter' }
        );


       },
    ),
   );
  }
}