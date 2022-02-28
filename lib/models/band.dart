
//v9 creacion de Modelo
class Band {
  
  //Propiedades

  //el backend generará el id automáticamente // yo agregué los ? para evitar error
  String? id;
  String? name;
  int? votes;

  //definimos el Constructor
  Band({//para poder asingar valoes en el Constructor
    this.id, this.name, this.votes
  });

  //cuando conectemos con el backend este responderá con un map, con el socket
  //por eso crearemos un Factory Constructor (recibe cierto tipo de argumentos y regresa un a nueva instancia de la clase Band)
  factory Band.fromMap(Map<String,dynamic> obj) {//aqui lo que recibe en obj un mapa<String, dynamic>
    return Band(
      id: obj['id'], //viene de obj uy busca el id
      name: obj['name'],
      votes: obj['votes']
    );
  }



}