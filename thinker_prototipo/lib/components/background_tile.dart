import 'dart:async';
import 'package:flame/components.dart';
import 'package:tinker/tinker_game.dart';

class BackgroundImage extends SpriteComponent with HasGameReference<TinkerGame> {
  final String imageName;

  BackgroundImage({required this.imageName});

  @override
  Future<void> onLoad() async {
    priority = -10;
    sprite = Sprite(game.images.fromCache('Background/$imageName'));
    size = Vector2(640, 360);
    position = Vector2.zero();
    return super.onLoad();
  }
}