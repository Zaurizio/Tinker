import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tinker/overlays/question_overlay.dart';
import 'package:tinker/tinker_game.dart';

class GameScreen extends StatelessWidget {
  final String startingLevel;
  const GameScreen({super.key, required this.startingLevel});

  @override
  Widget build(BuildContext context) {
    final game = TinkerGame(startingLevelName: startingLevel);

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'QuestionOverlay': (context, TinkerGame game) => QuestionOverlay(game: game),
            },
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
                  onTap: () => Navigator.of(context).pop(),
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