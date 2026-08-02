
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tinker/tinker_game.dart';

class JumpButton extends SpriteComponent
 with HasGameReference<TinkerGame>,TapCallbacks
 {
  JumpButton();

  final margin = 32;
  final buttonSize = 64;
@override
 FutureOr<void> onLoad(){
  sprite = Sprite(game.images.fromCache('hud/JumpButton.png'));
  position = Vector2(
    game.size.x - 32 - 64 - buttonSize,
     game.size.y -32 - 64 - buttonSize,
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