import 'package:cloud_firestore/cloud_firestore.dart';

class Relato {
  String? id;
  List<String>? fotos;
  String? usuario;
  bool coleira;
  String? corPelagem;
  bool desnutrido;
  bool docil;
  bool machucado;
  String? porte;
  String? localizacao;
  String? endereco;
  

  Relato({
    this.id,
    this.fotos,
    this.usuario,
    required this.coleira,
    this.corPelagem,
    required this.desnutrido,
    required this.docil,
    required this.machucado,
    this.porte,
    this.localizacao,
    this.endereco,

    
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fotos': fotos,
      'usuario': usuario,
      'coleira': coleira,
      'corPelagem': corPelagem,
      'desnutrido': desnutrido,
      'docil': docil,
      'machucado': machucado,
      'porte': porte,
      'localizacao': localizacao,
      'endereco': endereco,
    };
  }

  factory Relato.fromFireStore(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Relato(
      id: document.id,
      fotos: List<String>.from(data['fotos'] ?? []),
      usuario: data['usuario'],
      coleira: data['coleira'],
      corPelagem: data['corPelagem'],
      desnutrido: data['desnutrido'],
      docil: data['docil'],
      machucado: data['machucado'],
      porte: data['porte'],
      localizacao: data['localizacao'],
      endereco: data['endereco'],
    );
  }
}
