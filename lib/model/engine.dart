import 'dart:async';

import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';

const int TIME_SCALE = 24 * 60;//(24 * 60 * 60 / 60; // one minute is one day
const int TICK_MS = 4321; // tick every X ms
const Duration SCALED_TICK_DURATION = const Duration(milliseconds: TICK_MS * TIME_SCALE );

const double DEFAULT_QUEST_IN_TICK_PROBABILITY = 0.02;
const double DEFAULT_HERO_IN_TICK_PROBABILITY = 0.01;

class Engine {

  Game game;

  Stream<EngineEvent> events;
  StreamController<EngineEvent> _controller = new StreamController();

  double questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
  double heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;

  Engine(this.game) {
    _controller = new StreamController();
    events = _controller.stream;
  }

  void start() {
    Timer tickGenerator = new Timer.periodic(new Duration(milliseconds: TICK_MS), doTick);
  }

  void doTick(Timer timer) {

    bool dryRun = game.loggedUser == null;

    int day = game.currentTime.day;
    game.currentTime = game.currentTime.add(SCALED_TICK_DURATION);

    if (day != game.currentTime.day) {
      _controller.sink.add(new EngineEvent(EngineEventType.NEW_DAY));
      game.save();
    }
    if (!dryRun) {
      if (game.availableQuests.length < 20) {
        if (g.rnd.nextDouble() < questProbability) {
          Quest q = game.masterCatalogue.questCatalogue.createNew();
          _controller.sink.add(new EngineEvent(EngineEventType.NEW_QUEST, q));
          game.save();
          questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
        } else {
          questProbability = questProbability * 1.2;
        }
      }
      if (game.heroesToHire.length < 20) {
        if (g.rnd.nextDouble() < heroProbability) {
          Hero h = game.masterCatalogue.heroesCatalogue.createNew();
          _controller.sink.add(new EngineEvent(EngineEventType.NEW_HERO, h));
          game.save();
          heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;
        } else {
          heroProbability = heroProbability * 1.2;
        }
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
