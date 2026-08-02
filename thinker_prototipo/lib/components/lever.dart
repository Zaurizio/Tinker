import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tinker/components/laser.dart';

import 'package:tinker/tinker_game.dart';

class Lever extends SpriteComponent
    with HasGameReference<TinkerGame>, CollisionCallbacks {
  bool isOn = true;

  Lever({position, size}) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
    sprite = Sprite(game.images.fromCache('Traps/Laser/isOn.png'));
    return super.onLoad();
  }

 
  void onSolved() {
    isOn = false;
    sprite = Sprite(game.images.fromCache('Traps/Laser/isOff.png'));

    
    for (final laser in parent!.children.whereType<Laser>()) {
      laser.turnOff();
    }
  }
}