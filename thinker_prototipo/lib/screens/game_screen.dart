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
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'QuestionOverlay': (context, TinkerGame game) => QuestionOverlay(game: game),
        },
      ),
    );
  }
}