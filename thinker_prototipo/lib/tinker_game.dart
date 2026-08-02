import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:tinker/components/interaction_button.dart';
import 'package:tinker/components/jump_button.dart';
import 'package:tinker/components/level.dart';
import 'package:tinker/components/lever.dart';
import 'package:tinker/components/player.dart';
import 'package:tinker/components/portal.dart';
import 'package:tinker/data/question.dart';

class TinkerGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {

  final String startingLevelName;
  TinkerGame({required this.startingLevelName});

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  Player player = Player(character: 'Razor Bill');
  late JoystickComponent joystick;
  bool showControls = false;
  bool playSounds = true;
  double soundVolume = 1.0;
  List<String> levelNames = ['level_01', 'level_02'];
  int currentLevelIndex = 0;
  dynamic activeInteractable;
  Question? currentQuestion;

  @override
  FutureOr<void> onLoad() async {
  
    await images.loadAllImages();

    _loadLevel();

    if (showControls) {
      addJoystick();
      add(JumpButton());
    }
    
add(InteractButton());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('hud/knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('hud/joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
    
    


  }
  
void tryInteract() {
  final target = activeInteractable;
  if (target == null) return;

  if (target is Portal && !target.solved) {
    _startQuestion();
  } else if (target is Lever && target.isOn) {
    _startQuestion();
  }
}
void _startQuestion() {
  currentQuestion = pickRandomQuestion();
  pauseEngine();
  overlays.add('QuestionOverlay');
}

void resolveQuestion(bool correct) {
  overlays.remove('QuestionOverlay');
  resumeEngine();
  if (correct) {
    final target = activeInteractable;
    if (target is Portal) target.open();
    if (target is Lever) target.onSolved();
  }
  currentQuestion = null;
}
 
}
