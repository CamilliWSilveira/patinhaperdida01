import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:patinha_perdida/dao/relato_dao.dart';
import 'package:patinha_perdida/model/relato.dart';
import 'package:patinha_perdida/model/usuario.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CadastroRelato extends StatefulWidget {
  const CadastroRelato({super.key, this.id});

  final String? id;

  @override
  State<CadastroRelato> createState() => _CadastroRelatoState();
}

class _CadastroRelatoState extends State<CadastroRelato> {
  final TextEditingController _corPelagemController = TextEditingController();
  final TextEditingController _porteController = TextEditingController();
  XFile? _imagem;
  Relato? _relato;
  bool _carregando = false;
  final List<File> _imagens = List.empty(growable: true);
  final auth = FirebaseAuth.instance;

  _capturarFoto({bool camera = true}) async {
    XFile? temp;
    final ImagePicker picker = ImagePicker();

    if (camera) {
      temp = await picker.pickImage(source: ImageSource.camera);
    } else {
      temp = await picker.pickImage(source: ImageSource.gallery);
    }

    if (temp != null) {
      setState(() {
        _imagem = temp;
      });
    }
  }

  String _gerarNome() {
    final agora = DateTime.now();
    return agora.microsecondsSinceEpoch.toString();
  }

  Future<List<String>?> _salvarFoto(String id) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference pastaFotos = pastaRaiz.child(id).child("fotos");
    Reference arquivo;
    List<String> temp = List.empty(growable: true);

    try {
      for (File foto in _imagens) {
        arquivo = pastaFotos.child("${_gerarNome()}.jpg");
        TaskSnapshot task = await arquivo.putFile(foto);
        String url = await task.ref.getDownloadURL();
        temp.add(url);
      }

      return temp;
    } catch (e) {
      setState(() {
        _carregando = false;
      });
      print(e);
      return null;
    }
  }

  _salvarRelato({Relato? relato}) async {
    setState(() {
      _carregando = true;
    });

    final FirebaseAuth auth = FirebaseAuth.instance;
    String uID = auth.currentUser!.uid;

    final navigator = Navigator.of(context);
    List<String>? fotos = await _salvarFoto(uID);

    if (fotos != null) {
      Relato novoRelato = Relato(
        usuario: auth.currentUser!.email,
        coleira: coleira,
        corPelagem: _corPelagemController.text,
        desnutrido: desnutrido,
        docil: docil,
        machucado: machucado,
        porte: _porteController.text,
        fotos: fotos,
        localizacao: _localizacao.toString(),
        endereco: _endereco,
      );

      //Adiciona o novo relato usando o RelatoDAO
      await RelatoDAO().addRelato(novoRelato, "");
    }

    setState(() {
      _carregando = false;
    });

    navigator.pop();
  }

  _adicionarFoto() {
    setState(() {
      _imagens.add(File(_imagem!.path));
    });
  }

  List<Widget> _carrossel() {
    List<Widget> imagens = List.empty(growable: true);
    for (File imagem in _imagens) {
      Padding temp = Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Image.file(
          imagem,
          fit: BoxFit.cover,
          width: 200,
        ),
      );
      imagens.add(temp);
    }
    return imagens;
  }

  @override
  void dispose() {
    _corPelagemController.dispose();
    _porteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  bool coleira = false;
  bool machucado = false;
  bool desnutrido = false;
  bool docil = false;
  String? corPelagem;
  String? porte;
  Position? _localizacao;
  String? _endereco;

  Future _getLocalizacao() async {
    bool servicoHabilitado;
    LocationPermission permissao;

    servicoHabilitado = await Geolocator.isLocationServiceEnabled();

    if (!servicoHabilitado) {
      setState(() {
        _endereco = "Serviço de localização não está habilitado";
      });
      return;
    }
    permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();

      if (permissao == LocationPermission.denied) {
        setState(() {
          _endereco = "Permissão de localização negada!";
        });
        return;
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      setState(() {
        _endereco = "Permissão de localização negada permanentemente!";
      });
      return;
    }

    Position temp = await Geolocator.getCurrentPosition();

    setState(() {
      _localizacao = temp;
    });
  }

  _getEndereco() async {
    List<Placemark> enderecos = await placemarkFromCoordinates(
        _localizacao!.latitude, _localizacao!.longitude);

    if (enderecos.isNotEmpty) {
      Placemark endereco = enderecos[0];
      String? rua = endereco.thoroughfare;
      print(endereco.toString());
      setState(() {
        _endereco = rua;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              "Cadastro",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue,
            actions: [
              IconButton(
                onPressed: () => _salvarRelato(relato: _relato),
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("imagens/cadastroRelato.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 70, left: 32, right: 32, bottom: 64),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[900],
                            ),
                            onPressed: () => _capturarFoto(),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Câmera")),
                        TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[900],
                            ),
                            onPressed: () => _capturarFoto(camera: false),
                            icon: const Icon(Icons.image),
                            label: const Text("Galeria")),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _imagem != null
                          ? Image.file(
                              File(_imagem!.path),
                              fit: BoxFit.fill,
                            )
                          : Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          TextButton.icon(
                            onPressed: () => _adicionarFoto(),
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text("Adicionar Foto"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[900],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 40),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _carrossel(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("O animal possui coleira?"),
                              Switch(
                                  value: coleira,
                                  activeColor: Colors.amber[600],
                                  onChanged: (bool valor) {
                                    setState(() {
                                      coleira = valor;
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("O animal está machucado?"),
                              Switch(
                                  value: machucado,
                                  activeColor: Colors.amber[600],
                                  onChanged: (bool valor) {
                                    setState(() {
                                      machucado = valor;
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("O animal está desnutrido?"),
                              Switch(
                                  value: desnutrido,
                                  activeColor: Colors.amber[600],
                                  onChanged: (bool valor) {
                                    setState(() {
                                      desnutrido = valor;
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("O animal é dócil?"),
                              Switch(
                                  value: docil,
                                  activeColor: Colors.amber[600],
                                  onChanged: (bool valor) {
                                    setState(() {
                                      docil = valor;
                                    });
                                  }),
                            ],
                          ),
                          TextField(
                            controller: _corPelagemController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: "Cor da Pelagem",
                            ),
                          ),
                          TextField(
                            controller: _porteController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: "Porte",
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    await _getLocalizacao();
                                    _getEndereco();
                                  },
                                  child: const Text("Localização")),
                              Text(
                                _endereco ?? "",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_carregando)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black,
            ),
          ),
        if (_carregando)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
