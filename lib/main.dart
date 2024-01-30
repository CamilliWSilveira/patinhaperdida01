import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:patinha_perdida/telas/cadastro_usuario.dart';
import 'package:patinha_perdida/telas/home.dart';
import 'package:patinha_perdida/telas/login.dart';

void main() async {
  const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyCaql9bUwkdC8pDhEj6hjgRHKjkmC7UIE8",
      appId: "1:495539006024:android:b8ccd45645ab63ba9bc67d",
      messagingSenderId: "495539006024",
      projectId: "patinha-perdida-31cdf",
      storageBucket: "patinha-perdida-31cdf.appspot.com");
  const FirebaseOptions ios = FirebaseOptions(
      apiKey: "AIzaSyDAsIWBolVUE18RXZdZAp6n3oeWRwzKJ5c",
      appId: "1:495539006024:ios:03ed0febf6470a779bc67d",
      messagingSenderId: "495539006024",
      projectId: "patinha-perdida-31cdf",
      storageBucket: "patinha-perdida-31cdf.appspot.com");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: Platform.isAndroid ? android : ios);

  runApp(const MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ],
    supportedLocales: [
      Locale("pt"),
    ],
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}
