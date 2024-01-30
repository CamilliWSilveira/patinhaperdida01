import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? nome;
  String? email;
  String? senha;

  Usuario(this.nome, this.email, this.senha);

  Map<String, dynamic> ToFirestore() {
    return {
      "nome": nome,
      "email": email,
      "senha": senha,
    };
  }

  Usuario.fromJson(Map<String, dynamic> json)
      : nome = json["nome"],
        email = json["email"],
        senha = json["senha"];

  factory Usuario.fromFirestorm(DocumentSnapshot doc) {
    final dados = doc.data()! as Map<String, dynamic>;
    return Usuario.fromJson(dados);
  }

  @override
  String toString() {
    return "nome: $nome\nE-mail: $email\nsenha: $senha";
  }
}
