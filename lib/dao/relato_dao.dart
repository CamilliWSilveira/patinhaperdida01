import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patinha_perdida/model/relato.dart';

class RelatoDAO {
  final CollectionReference colecao =
      FirebaseFirestore.instance.collection("relatos");

  Future<void> addRelato(Relato relato, String doc) {
    return colecao.add(relato.toFirestore());
  }
}
