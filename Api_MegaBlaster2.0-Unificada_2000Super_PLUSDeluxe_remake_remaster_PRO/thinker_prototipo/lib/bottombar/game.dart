import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinker/screens/title_screen.dart';

class GameTab extends StatefulWidget {
  const GameTab({super.key});

  @override
  State<GameTab> createState() => _GameTabState();
}

class _GameTabState extends State<GameTab> {
  @override
  void initState() {
    super.initState();
    // trava em paisagem assim que entra na secao do jogo
    // (vale pra Title, LevelSelect e Game, ja que todas ficam "dentro" dessa tela)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // ao sair da secao do jogo por completo (voltar pra Home/Perfil), volta pro retrato
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const TitleScreen();
  }
}