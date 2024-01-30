import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patinha_perdida/telas/home.dart';

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({Key? key}) : super(key: key);

  @override
  _CadastroUsuarioState createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  var firestore = FirebaseFirestore.instance;
  var auth = FirebaseAuth.instance;

  TextEditingController _nomeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Usuário',
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/cadastroRelato.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nomeController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  backgroundColor: Color.fromARGB(255, 255, 217, 0),
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () async {
                  try {
                    final Credential =
                        await auth.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _senhaController.text,
                    );

                    // Mostrar pop-up de sucesso
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Sucesso"),
                          content: Text("Usuário cadastrado com sucesso!"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                final credencial =
                                    await auth.signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _senhaController.text,
                                );
                                Navigator.of(context).pop(); // Fechar o pop-up
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ),
                                );
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } on FirebaseAuthException catch (e) {
                    // Mostrar pop-up de erro
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Erro"),
                          content: Text(
                            e.code == "weak-password"
                                ? "A senha fornecida é fraca"
                                : e.code == "email-already-in-use"
                                    ? "E-mail já está em uso"
                                    : "Erro desconhecido",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fechar o pop-up
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    // Mostrar pop-up de erro desconhecido
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Erro"),
                          content: Text("Ocorreu um erro desconhecido."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fechar o pop-up
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
