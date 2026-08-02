import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/services.dart';
import 'package:tinker/components/checkpoint.dart';
import 'package:tinker/components/collision_block.dart';
import 'package:tinker/components/custom_hitbox.dart';
import 'package:tinker/components/fruit.dart';
import 'package:tinker/components/gasbomb.dart';
import 'package:tinker/components/laser.dart';
import 'package:tinker/components/lever.dart';
import 'package:tinker/components/portal.dart';
import 'package:tinker/components/saw.dart';
import 'package:tinker/components/utils.dart';
import 'package:tinker/tinker_game.dart';

enum PlayerState { idle, running, jumping, falling, hit, appearing, disappearing}

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<TinkerGame>, KeyboardHandler,CollisionCallbacks {
  String character;
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);
  
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4, 
    width: 14,
    height: 28);

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
   // debugMode = true;

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(!gotHit && !reachedCheckpoint){
      accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      _updatePlayerState();
      _updatePlayerMovement(fixedDeltaTime);
      _checkHorizontalCollisions();
      _applyGravity(fixedDeltaTime);
      _checkVerticalCollisions();

      accumulatedTime -= fixedDeltaTime;
    }

    }
    

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      hasJumped = true;
    }if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyE) {
  game.tryInteract();
}

    return super.onKeyEvent(event, keysPressed);
  }

    @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
   if(!reachedCheckpoint){
    if (other is Fruit) other.collidingWithPlayer();
    if (other is Saw) _respawn();
    if (other is Laser && other.isOn) _respawn();  
    if (other is GasBomb) _respawn();
    if (other is Checkpoint && !reachedCheckpoint) _reachedCheckpoint();
    if (other is Portal || other is Lever) game.activeInteractable = other;
    }
    super.onCollisionStart(intersectionPoints, other);
  }
   
  void _loadAllAnimations() {
    idleAnimation = _SpriteAnimation('Idle', 11);
    runningAnimation = _SpriteAnimation('Run', 15);
    jumpingAnimation = _SpriteAnimation('Jump', 1);
    fallingAnimation = _SpriteAnimation('Fall', 1);
    hitAnimation = _SpriteAnimation('Hit', 7)..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
      
      
    };
    current = PlayerState.idle;
  }
@override
void render(Canvas canvas) {
  canvas.save();
  canvas.translate(
    position.x.roundToDouble() - position.x,
    position.y.roundToDouble() - position.y,
  );
  super.render(canvas);
  canvas.restore();
}
  SpriteAnimation _SpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

    SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

  

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    if(velocity.y > 0 ) playerState = PlayerState.falling;

    if(velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _checkHorizontalCollisions() {
  for (final block in collisionBlocks) {
    if (!block.isPlatform) {
      if (checkCollisions(this, block)) {
        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = block.x - hitbox.offsetX - hitbox.width;
          break;
        }
        if (velocity.x < 0) {
          velocity.x = 0;
          position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
          break;
        }
      }
    }
  }
}

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

   void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollisions(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollisions(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }
  
  void _respawn() async{
  
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      current = PlayerState.appearing;

      await animationTicker?.completed;
      animationTicker?.reset();

        velocity = Vector2.zero();
        position = startingPosition;
        _updatePlayerState();
        Future.delayed(canMoveDuration, () => gotHit = false);


  
  }
  
  void _reachedCheckpoint() {
    reachedCheckpoint = true;
    if(scale.x > 0){
      position = position - Vector2.all(32);

    }else if (scale.x <0){
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;

    const reachedCheckpointDuration = Duration(milliseconds: 350);
    Future.delayed(reachedCheckpointDuration, (){
      reachedCheckpoint = false;
      position = Vector2.all(-640);

      const waitToChangeDuration = Duration(seconds:3);  
      Future.delayed(waitToChangeDuration, (){

      });
    });
  }
}