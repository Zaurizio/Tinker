import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tinker/tinker_game.dart';

class Laser extends SpriteAnimationComponent
    with HasGameReference<TinkerGame>, CollisionCallbacks {
  Laser({position, size}) : super(position: position, size: size);

  static const double laserSpeed = 0.05;
  late final SpriteAnimation onAnimation;
  late final SpriteAnimation offAnimation;
  bool isOn = true;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());

    final image = game.images.fromCache('Traps/Laser/laser.png');

    onAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 11,
        stepTime: laserSpeed,
        textureSize: Vector2(16, 64),
      ),
    );

    offAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2(16, 64),
      ),
    );

    animation = onAnimation;
    return super.onLoad();
  }

  void turnOff() {
    isOn = false;
    animation = offAnimation;
  }
}