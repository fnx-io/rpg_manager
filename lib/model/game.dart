import 'dart:async';

import 'package:firebase3/firebase.dart';
import 'package:rpg_manager/engine/engine.dart';
import 'package:rpg_manager/engine/commands.dart' as commands;
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/model/skills.dart';

int _id = new DateTime.now().millisecondsSinceEpoch;

int generateId() => _id++;

class Game {

  int id = 1;

  HeroesCatalogue heroesCatalogue;
  QuestCatalogue questCatalogue;
  SkillCatalogue skillCatalogue = new SkillCatalogue();

  User loggedUser;

  List<QuestResult> questResults = [];

  Iterable<Hero> get heroesToHire => heroesCatalogue.all.where((Hero h) => !h.hired);

  Iterable<Hero> get hiredHeroes => heroesCatalogue.all.where((Hero h) => h.hired);

  Iterable<Quest> get availableQuests => questCatalogue.all.where((Quest q) => !q.inProgress);

  Iterable<Quest> get questsInProgress => questCatalogue.all.where((Quest q) => q.inProgress);

  int money = 500;

  DateTime currentTime;

  Game() {
    heroesCatalogue = new HeroesCatalogue(this);
    questCatalogue = new QuestCatalogue(this);
  }

  Map<String, Object> toMap() {
    Map<String,Object> result = {};
    result["currentTime"] = currentTime.millisecondsSinceEpoch;
    result["money"] = money;

    result["heroes"] = heroesCatalogue.all.map((Hero h) => h.toMap()).toList();
    result["quests"] = questCatalogue.all.map((Quest q) => q.toMap()).toList();

    return result;
  }

  void fromMap(Map data) {
    currentTime = new DateTime.fromMillisecondsSinceEpoch(data["currentTime"]);
    money = data["money"];

    (data["quests"] as List).forEach((Map m) {
      Quest q = new Quest();
      q.fromMap(m, this);
      questCatalogue.registerExisting(q);
    });

    (data["heroes"] as List).forEach((Map m) {
      Hero h = new Hero();
      h.fromMap(m, this);
      heroesCatalogue.registerExisting(h);
    });

  }

}