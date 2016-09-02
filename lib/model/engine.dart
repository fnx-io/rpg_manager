import 'dart:async';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/names.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/model/skills.dart';

const int TIME_SCALE = 24 * 60;//(24 * 60 * 60 / 60; // one minute is one day
const int TICK_MS = 4321; // tick every X ms
const Duration SCALED_TICK_DURATION = const Duration(milliseconds: TICK_MS * TIME_SCALE );

const double DEFAULT_QUEST_IN_TICK_PROBABILITY = 0.02;
const double DEFAULT_HERO_IN_TICK_PROBABILITY = 0.01;

class Engine {

  Game game;

  Stream<EngineEvent> events = null;
  StreamController<EngineEvent> _controller = new StreamController();

  double questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
  double heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;

  Engine(this.game) {
    initGame();

    _controller = new StreamController();
    events = _controller.stream;

  }

  void initGame() {
    game.currentTime = new DateTime(267, 1, 1, 12, 0);
    if (game.heroesToHire.isEmpty) {
      for (int a = 0; a < 15; a++) {
        game.heroesToHire.add(generateHero());
      }
    }
    if (game.availableQuests.isEmpty) {
      {
        for (int a = 0; a < 15; a++) {
          game.availableQuests.add(generateQuest());
        }
      }
    }


    Timer tickGenerator = new Timer.periodic(new Duration(milliseconds: TICK_MS), doTick);
  }

  void doTick(Timer timer) {
    int day = game.currentTime.day;
    game.currentTime = game.currentTime.add(SCALED_TICK_DURATION);

    if (day != game.currentTime.day) {
      _controller.sink.add(new EngineEvent(EngineEventType.NEW_DAY));
    }
    if (game.availableQuests.length < 20) {
      if (g.rnd.nextDouble() < questProbability) {
        Quest q = generateQuest();
        game.availableQuests.add(q);
        _controller.sink.add(new EngineEvent(EngineEventType.NEW_QUEST, q));
        questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
      } else {
        questProbability = questProbability * 1.2;
      }
    }

    if (game.heroesToHire.length < 20) {
      if (g.rnd.nextDouble() < heroProbability) {
        Hero h = generateHero();
        game.heroesToHire.add(h);
        _controller.sink.add(new EngineEvent(EngineEventType.NEW_HERO, h));
        heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;
      } else {
        heroProbability = heroProbability * 1.2;
      }
    }
    _controller.sink.add(new EngineEvent(EngineEventType.TICK));
  }


}

enum EngineEventType {
  TICK, NEW_DAY, NEW_QUEST, NEW_HERO
}

class EngineEvent {

  EngineEventType type;
  Object param;

  EngineEvent(this.type, [this.param]);

}
