///clase para  cominucarme con el servidor (node express), usando provider

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//manejop de status definido por nosotros
enum ServerStatus{
  Online,
  Offilne,
  Connecting //cuando inicie la app va a estar en Connecting
}


//nos ayudara a decirle a provider cuando refresacar la UI, o Widget en particular, si sucede algun cambio
//o cuando notifique a quienes trabajan con Socket Service
class SocketService with ChangeNotifier{

  //se crea la propiedad y se asigna estado Connecting
  ServerStatus _serverStatus = ServerStatus.Connecting;

  //para exponer el on.. y emitir Eventos desde la app
  //lo ponemos como propiedad privada
  late IO.Socket _socket;
  //para exponer el socket, por medio de la propiedad //para escuchar .. necesitaremos el off
  IO.Socket get socket => this._socket;
  //para simplificar el codigi
  Function get emit => this._socket.emit;

  //para "EXPONER" _serverStatus hacemos un getter, para accederlo como propiedad, //agregamos el tipo ServerStatus
  //para controlar la manera en que cambia
  ServerStatus get serverStatus => this._serverStatus;



  //constructor
  SocketService(){
    //cuando se crea una instancia del SocketService se llama al _initConfig
    this._initCongig();

  }

  //para no cargar el constructor con mucha info
  //se crea metodo privado
  void _initCongig(){

    //agregamos los LISTENERS
    
    //pegamos desde la documentacion de socket io client, 
    //agregamos argumentos en el IO.io 'transports'
    this._socket = IO.io(
      //cambio en video, posteriormente se hara en direccion de cloud
      'http://192.168.1.85:3000/',{
      // 'http://localhost:3000/',{
        //nos comunicaremos a traves de websockets
        'transports':['websocket'],
        //conectarnos automaticamente o a determinado momento
        'autoConnect':true
      
    });

    this._socket.on('connect', (_){
    // socket.onConnect((_) { //nueva forma
      // print('connected to server');/
      
      //cambio de estado a online
      this._serverStatus = ServerStatus.Online;
      //despues de poner online notificamos listeners
      notifyListeners();



      // socket.emit('msg', 'test');
    });

    // socket.on('event', (data) => print(data));
    
    // socket.onDisconnect((_) { //nueva forma
    this._socket.on('disconnect', (_) {      
      //print('disconnected from server');

      //cambiamos el estado a offline
      this._serverStatus = ServerStatus.Offilne;
      notifyListeners();
    } );
    // socket.on('fromServer', (_) => print(_));

    // //Escuchar evento del Servidor
    // //evento que escucha evento 'nuevo-mensaje' ( que el servidor genera al recibir 'emitir-mensaje'  )
    //  socket.on('nuevo-mensaje', ( payload ){
       
    //    //imprime un texto con el payload del cliente inicial (Chrome consola) socket.emit('emitir-mensaje','David Chrome');
    //    print('Evento: nuevo-mensaje: '); //I/flutter (13011): nuevo-mensaje David Chrome
    //    //socket.emit('emitir-mensaje',{nombre:'David Chrome', mensaje:'Hola Chrome'});

    //    //socket.emit('emitir-mensaje',{nombre:'David Chrome', mensaje:'Hola Chrome', ubicacionperdida: '' });
    //    print('Payload (RAW): $payload');
    //    print('Payload (indexao):');
    //    print('Nombre: ' + payload['nombre']);
    //    print('Mensaje: ' + payload['mensaje']);
    //    print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay mas info');

    //   // this._serverStatus = ServerStatus.Online;
    //   // notifyListeners();

    // });

    //Para EMITIR un evento desde la app
    //tenemos que exponer el on
    



  }
}