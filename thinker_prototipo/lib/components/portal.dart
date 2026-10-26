import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:tinker/tinker_game.dart';
import 'package:tinker/components/collision_block.dart';

class Portal extends SpriteAnimationComponent
    with HasGameReference<TinkerGame>, CollisionCallbacks {
  static const double frameStepTime = 0.05; 

  bool solved = false;
  bool playerInRange = false;

  late final SpriteAnimation closedAnimation;
  late final SpriteAnimation openAnimation;
  CollisionBlock? blocker;
  List<CollisionBlock>? levelCollisionBlocks;

  Portal({position, size}) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() {
  
    add(RectangleHitbox(collisionType: CollisionType.passive));

    final image = game.images.fromCache('Traps/Portal/PortaoMagico.png');

   
    closedAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2(16, 64),
      ),
    );

   
    openAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 18,
        stepTime: frameStepTime,
        textureSize: Vector2(16, 64),
        loop: false,
      ),
    );

    animation = closedAnimation;
    return super.onLoad();
  }

  

  void open() {
    if (solved) return;
  solved = true;
  animation = openAnimation;

  blocker?.removeFromParent();
  levelCollisionBlocks?.remove(blocker);

  Future.delayed(
    Duration(milliseconds: (18 * frameStepTime * 1000).round()),
   
  );
  }
}