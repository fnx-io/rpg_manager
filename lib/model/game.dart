import 'dart:async';
import 'dart:math';

import 'package:rpg_manager/model/engine.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';

class Game {

  List<Hero> heroesToHire = [];
  List<Hero> hiredHeroes = [];
  List<Quest> availableQuests = [];
  List<Quest> questsInProgress = [];

  int money = 500;

  DateTime currentTime;
  Engine engine;

  Game() {
    engine = new Engine(this);
  }

  void hireHero(Hero h) {
    hiredHeroes.add(h);
    heroesToHire.remove(h);
    h.hired = true;
  }

  void fireHero(Hero h) {
    hiredHeroes.remove(h);
    heroesToHire.add(h);
    h.hired = false;
  }

  void attemptQuest(Quest q) {
    q.started = currentTime;
    q.finish = q.started.add(new Duration(days: q.duration));
    availableQuests.remove(q);
    questsInProgress.add(q);
  }

}