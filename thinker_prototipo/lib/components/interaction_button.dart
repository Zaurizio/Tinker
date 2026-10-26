import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tinker/tinker_game.dart';
import 'package:tinker/components/jump_button.dart';

class InteractButton extends SpriteComponent
    with HasGameReference<TinkerGame>, TapCallbacks {
  InteractButton()
      : super(
          size: Vector2.all(48),
        );

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('hud/Action.png'));
    // Fica alinhado com o JumpButton, só que um pouco acima dele.
    final tamanhoViewport = game.cam.viewport.size;
    position = Vector2(
      tamanhoViewport.x - JumpButton.margin - size.x,
      tamanhoViewport.y - JumpButton.margin - 64 - 20 - size.y,
    );
    priority = 999;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.tryInteract();
  }
}