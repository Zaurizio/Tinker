import 'package:flutter/material.dart';
import 'package:tinker/homepage.dart';
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

          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.black.withOpacity(0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const Homepage()),
                    (route) => false,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.home_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}