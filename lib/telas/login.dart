import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patinha_perdida/telas/cadastro_usuario.dart';
import 'package:patinha_perdida/telas/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String? _erro;

  final auth = FirebaseAuth.instance;

  _login() async {
    final navigator = Navigator.of(context);
    try {
      final credencial = await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _senhaController.text,
      );

      if (credencial.user != null) {
        navigator.pushReplacement(MaterialPageRoute(
          builder: (context) => const Home(),
        ));
      }
    } on FirebaseAuthException catch (e) {
      print("Código de erro: ${e.code}");

      String mensagem = "";

      if (e.code == 'user-not-found') {
        mensagem = "E-mail não cadastrado. Deseja criar uma conta?";
      } else if (e.code == 'wrong-password') {
        mensagem = "Senha incorreta. Esqueceu sua senha?";
      } else if (e.code == 'INVALID_LOGIN_PREDATIONS') {
        mensagem = "Login inválido";
      } else {
        mensagem = "Erro desconhecido";
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erro no login"),
            content: Text(mensagem),
            actions: [
              if (e.code == 'user-not-found')
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(CadastroUsuario());
                  },
                  child: Text("Criar Conta"),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future _verificarLogin() async {
    final User? usuario = auth.currentUser;

    if (usuario != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    _verificarLogin().then((sucesso) {
      if (sucesso) {
        navigator.pushReplacement(MaterialPageRoute(
          builder: (context) => const Home(),
        ));
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 340, bottom: 70),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                          cursorColor: Colors.black,
                          cursorWidth: 2.0,
                          cursorRadius: Radius.circular(1.0),
                          decoration: InputDecoration(
                            labelText: "E-mail",
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: _senhaController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                          cursorColor: Colors.black,
                          cursorWidth: 2.0,
                          cursorRadius: Radius.circular(1.0),
                          decoration: InputDecoration(
                            labelText: "Senha",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _erro ?? "",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          onPressed: () => _login(),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            backgroundColor: Color.fromARGB(255, 255, 217, 0),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          child: const Text("Entrar"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "Ainda não possui uma conta?",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16),
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CadastroUsuario(),
                              ),
                            );
                          },
                          child: const Text(
                            "Clique Aqui!",
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 255, 217, 0),
                                fontSize: 18),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
