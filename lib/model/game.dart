import 'dart:async';

import 'package:firebase3/firebase.dart';
import 'package:rpg_manager/model/engine.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/model/skills.dart';

int _id = new DateTime.now().millisecondsSinceEpoch;

int generateId() => _id++;

class Game {

  int id = 1;

  Database database;

  DatabaseReference firebase;

  User loggedUser;

  List<QuestResult> questResults = [];

  Iterable<Hero> get heroesToHire => masterCatalogue.heroesCatalogue.all.where((Hero h) => !h.hired);

  Iterable<Hero> get hiredHeroes => masterCatalogue.heroesCatalogue.all.where((Hero h) => h.hired);

  Iterable<Quest> get availableQuests => masterCatalogue.questCatalogue.all.where((Quest q) => !q.inProgress);

  Iterable<Quest> get questsInProgress => masterCatalogue.questCatalogue.all.where((Quest q) => q.inProgress);

  int money = 500;

  DateTime currentTime;

  MasterCatalogue masterCatalogue = new MasterCatalogue();

  Engine engine;

  Game(this.database) {
    engine = new Engine(this);
  }

  void hireHero(Hero h) {
    assert(!h.dead);
    h.hired = true;
  }

  void fireHero(Hero h) {
    assert(!h.dead);
    h.hired = false;
  }

  void attemptQuest(Quest q) {
    q.started = currentTime;
    q.finish = q.started.add(new Duration(days: q.duration));
  }

  Future initWithUser(User user) async {
    firebase = database.ref(user.uid).child("game");

    Map data = (await firebase.once("value")).snapshot.val();

    if (data == null) {
      currentTime = new DateTime(267, 1, 1, 12, 0);

      for (int a = 0; a < 15; a++) {
        masterCatalogue.questCatalogue.createNew();
      }

      for (int a = 0; a < 15; a++) {
        masterCatalogue.heroesCatalogue.createNew();
      }
      save();
    } else {
      fromMap(data);
    }

    loggedUser = user;

    engine.start();

    return true;
  }

  void save() {
    firebase.set(toMap()).then((_) => print("Game saved ..."));
  }

  Map<String, Object> toMap() {
    Map<String,Object> result = {};
    result["currentTime"] = currentTime.millisecondsSinceEpoch;
    result["money"] = money;

    result["heroes"] = masterCatalogue.heroesCatalogue.all.map((Hero h) => h.toMap()).toList();
    result["quests"] = masterCatalogue.questCatalogue.all.map((Quest q) => q.toMap()).toList();

    return result;
  }

  void fromMap(Map data) {
    currentTime = new DateTime.fromMillisecondsSinceEpoch(data["currentTime"]);
    money = data["money"];

    (data["quests"] as List).forEach((Map m) {
      Quest q = new Quest();
      q.fromMap(m, masterCatalogue);
      masterCatalogue.questCatalogue.register(q);
    });

    (data["heroes"] as List).forEach((Map m) {
      Hero h = new Hero();
      h.fromMap(m, masterCatalogue);
      masterCatalogue.heroesCatalogue.register(h);
    });

  }

}

class MasterCatalogue {

  HeroesCatalogue heroesCatalogue;
  QuestCatalogue questCatalogue;
  SkillCatalogue skillCatalogue = new SkillCatalogue();

  MasterCatalogue() {
    heroesCatalogue = new HeroesCatalogue(this);
    questCatalogue = new QuestCatalogue(this);
  }


}
