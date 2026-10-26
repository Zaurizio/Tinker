import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tinker/components/background_tile.dart';
import 'package:tinker/components/checkpoint.dart';
import 'package:tinker/components/collision_block.dart';
import 'package:tinker/components/fruit.dart';
import 'package:tinker/components/gasbomb.dart';
import 'package:tinker/components/laser.dart';
import 'package:tinker/components/lever.dart';
import 'package:tinker/components/player.dart';
import 'package:tinker/components/portal.dart';
import 'package:tinker/components/saw.dart';
import 'package:tinker/tinker_game.dart';

class Level extends World with HasGameReference<TinkerGame>{
final String levelName;
final Player player;
Level({required this.levelName, required this.player});
late TiledComponent level;
List<CollisionBlock> collisionBlocks = [];

@override
  Future<void> onLoad() async{
 level = await TiledComponent.load(
  "$levelName.tmx",
  Vector2.all(16),
  layerPaintFactory: (opacity) => Paint()
    ..filterQuality = FilterQuality.none
    ..color = Color.fromRGBO(255, 255, 255, opacity),
);
   
    level.debugMode = true;
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

   
   
    return super.onLoad();
  }
  
  void _scrollingBackground() {
  final backgroundLayer = level.tileMap.getLayer('Background');
 
  if (backgroundLayer != null) {
    final backgroundName = backgroundLayer.properties.getValue<String>('BackgroundColor') ;
      

    add(BackgroundImage(imageName: '$backgroundName.png'));
  }
}
  
  void _spawningObjects() {
     final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if(spawnPointsLayer != null){
    for(final spawnPoint in spawnPointsLayer.objects){
    switch (spawnPoint.class_) {
      case 'Player': 
        player.position = Vector2(spawnPoint.x, spawnPoint.y);
        player.startingPosition = Vector2(spawnPoint.x, spawnPoint.y);
        player.scale.x = 1;
        add(player);
        break;
        case 'Fruit':
        final fruit = Fruit(
          fruit: spawnPoint.name,
          position: Vector2(spawnPoint.x, spawnPoint.y),
          size: Vector2(spawnPoint.width, spawnPoint.height)
        );
        add(fruit);
        break;
        case 'Saw':
        final isVertical = spawnPoint.properties.getValue('isVertical');
         final offNeg = spawnPoint.properties.getValue('offNeg');
          final offPos = spawnPoint.properties.getValue('offPos');

        final saw = Saw(
          isVertical: isVertical,
          offNeg: offNeg,
          offPos: offPos,  
          position: Vector2(spawnPoint.x, spawnPoint.y),
          size:Vector2(spawnPoint.width, spawnPoint.height),
        );
       add(saw);
        break;
        case 'Checkpoint':
        final checkpoint = Checkpoint(
          position: Vector2(spawnPoint.x, spawnPoint.y),
          size:Vector2(spawnPoint.width, spawnPoint.height),
        );
        add(checkpoint);
        break;
        case 'Portal':
    final blocker = CollisionBlock(
        position: Vector2(spawnPoint.x, spawnPoint.y),
        size: Vector2(spawnPoint.width, spawnPoint.height),
      );
      collisionBlocks.add(blocker);
      add(blocker);

      final portal = Portal(
        position: Vector2(spawnPoint.x, spawnPoint.y),
        size: Vector2(spawnPoint.width, spawnPoint.height),
    );
    portal.blocker = blocker;
    portal.levelCollisionBlocks = collisionBlocks;
      add(portal);
       break;
       case'GasBomb':
        final gasbomb = GasBomb(
          position: Vector2(spawnPoint.x, spawnPoint.y),
        size: Vector2(spawnPoint.width, spawnPoint.height),
        );
        add(gasbomb);
        break;
        case'Laser':
        final laser = Laser(
          position: Vector2(spawnPoint.x, spawnPoint.y),
        size: Vector2(spawnPoint.width, spawnPoint.height),
        );
        add(laser);
        break;
        case'Lever':
        final lever =Lever( 
           position: Vector2(spawnPoint.x, spawnPoint.y),
        size: Vector2(spawnPoint.width, spawnPoint.height),
        );
        add(lever);
        break;
      default:
    }
    }
    }

  }
  
  void _addCollisions() {
     final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    
    if(collisionsLayer != null){
        for(final collision in collisionsLayer.objects){
          switch (collision.class_) {

            case 'Platform':
              final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true,
              );
              collisionBlocks.add(platform);
              add(platform);
              break;
            default:
            final block = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
          }
        }
    }
    player.collisionBlocks = collisionBlocks;
  }
}