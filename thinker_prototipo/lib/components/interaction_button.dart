import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tinker/tinker_game.dart';

class InteractButton extends SpriteComponent
    with HasGameReference<TinkerGame>, TapCallbacks {
  InteractButton()
      : super(
          size: Vector2.all(48),
          position: Vector2(0, 0), 
        );

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('hud/Action.png'));
    position = Vector2(game.size.x - 80, game.size.y - 200); 
    priority = 999;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.tryInteract();
  }
}