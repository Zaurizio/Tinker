import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tinker/tinker_game.dart';

class GasBomb extends SpriteAnimationComponent with HasGameReference<TinkerGame>{

GasBomb({
    
    position,
    size,
     }) : super (
        position: position, 
        size: size
      );


      static const double gasSpeed = 0.05;

      @override
      FutureOr <void> onLoad(){
       // debugMode = true;
          add(CircleHitbox());


           animation = SpriteAnimation.fromFrameData(game.images.fromCache('Traps/GasBomb/GasBomb.png'), SpriteAnimationData.sequenced(
      amount: 14,
      stepTime: gasSpeed,
       textureSize: Vector2.all(48)
       ));
    return super.onLoad();
      }
}