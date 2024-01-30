import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:patinha_perdida/model/relato.dart';
import 'package:patinha_perdida/telas/cadastro_relato.dart';
import 'package:patinha_perdida/telas/login.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var auth = FirebaseAuth.instance;
  var firestore = FirebaseFirestore.instance;

  List<Widget> _carrossel(List<dynamic> fotos) {
    List<Widget> imagens = List.empty(growable: true);
    for (String imagem in fotos) {
      Padding temp = Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Image.network(
          imagem,
          fit: BoxFit.cover,
          width: 200,
        ),
      );
      imagens.add(temp);
    }
    return imagens;
  }

  Future _verificarLogin() async {
    final User? usuario = auth.currentUser;

    if (usuario != null) {
      return true;
    } else {
      return false;
    }
  }

  void _sairDoAplicativo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sair do aplicativo"),
          content: Text("Tem certeza de que deseja sair do aplicativo?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o pop-up
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o pop-up antes de sair
                SystemNavigator
                    .pop(); // Sair do aplicativo e voltar à tela inicial do aparelho
              },
              child: Text("Sair"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PATINHA PERDIDA",
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _sairDoAplicativo,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/relatos.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("relatos")
                    .orderBy("usuario", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Erro ao recuperar os dados",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<DocumentSnapshot> documentos = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: documentos.length,
                    itemBuilder: (context, index) {
                      Relato relato = Relato.fromFireStore(documentos[index]);

                      return Card(
                        color: Colors.amber[100]
                            ?.withOpacity(0.8), // Amarelo claro com opacidade
                        child: Column(
                          children: [
                            relato.fotos != null
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _carrossel(relato.fotos!),
                                    ),
                                  )
                                : Container(),
                            ListTile(
                              title: Text(
                                relato.usuario!,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Coleira: ${relato.coleira ? "Sim" : "Não"}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text:
                                          'Cor da Pelagem: ${relato.corPelagem}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text:
                                          'Desnutrido: ${relato.desnutrido ? "Sim" : "Não"}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text:
                                          'Docil: ${relato.docil ? "Sim" : "Não"}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text:
                                          'Machucado: ${relato.machucado ? "Sim" : "Não"}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text: 'Porte: ${relato.porte}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text:
                                          'Localização:\n ${relato.localizacao}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text: 'Endereço: ${relato.endereco}\n',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          if (auth.currentUser != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CadastroRelato(),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Usuário não logado"),
                  content: Text(
                      "Você precisa estar logado para prosseguir para esta tela!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fechar o pop-up
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ),
                        );
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
