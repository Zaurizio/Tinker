import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tinker/tinker_game.dart';

class JumpButton extends SpriteComponent
 with HasGameReference<TinkerGame>,TapCallbacks
 {
  JumpButton() : super(size: Vector2.all(64));

  static const double margin = 56;

@override
 FutureOr<void> onLoad(){
  sprite = Sprite(game.images.fromCache('hud/JumpButton.png'));
  final tamanhoViewport = game.cam.viewport.size;
  position = Vector2(
    tamanhoViewport.x - margin - size.x,
    tamanhoViewport.y - margin - size.y,
    );
    priority = 10;
  return super.onLoad();
 }
 @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}