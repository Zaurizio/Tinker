import 'package:flutter/material.dart';
import 'package:tinker/Services/sessao_atual.dart';
import 'package:tinker/screens/title_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

 
  SessaoAtual.token = Uri.base.queryParameters['token'];

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TitleScreen(),
    ),
  );
}