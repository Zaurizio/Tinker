import 'package:flutter/material.dart';
import 'package:tinker/screens/level_select_screen.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/UI/Tela.png',
            width: 900,
          ),

          Align(
            alignment: const Alignment(0, 0.55),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                  );
                },
                child: Image.asset(
                  'assets/images/UI/PlayButton.png',
                  width: 80,
                  height: 80,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}