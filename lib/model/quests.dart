import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/names.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:angular2/src/facade/lang.dart';

typedef List<Skill> RequestedSkillsBuilder();

class QuestRecipe {

  String name;
  String description;
  String icon;
  int money;
  int experience;
  int duration = 1;
  RequestedSkillsBuilder builder;

}

class Quest {

  String name;
  g.Difficulty overallDifficulty;
  QuestRecipe recipe;
  List<SkillRequirement> requiredSkills = [];

  int money;
  int experience;
  int duration;
  int minHeroes;

  DateTime started;
  DateTime finish;

  bool get inProgress => started != null;

  double progress(DateTime now) {
    if (started == null) return 0.0;
    if (finish == null) return 0.0;
    if (now == null) return 0.0;
    if (now.isBefore(started)) return 0.0;
    if (now.isAfter(finish)) return 1.0;
    return (now.difference(started)).inMinutes / (finish.difference(started)).inMinutes;
  }

}

class SkillRequirement {

  Skill skill;
  bool singleHero;
  g.Difficulty difficulty;
}

Quest generateQuest() {
  if (QUEST_COOKBOOK == null) {
    buildQuestCookbook();
  }

  QuestRecipe qr = g.rndItem(QUEST_COOKBOOK);
  g.Difficulty d = g.rndItem(g.Difficulty.difficulties);

  Quest q = new Quest();
  q.overallDifficulty = d;
  q.recipe = qr;
  q.name = qr.name + " at " + generatePlaceName();
  q.requiredSkills = buildSkillRequirements(qr.builder(), d);
  q.money = (qr.money * d.rewardCoeficient).round();
  q.experience = (qr.experience * d.rewardCoeficient).round();
  q.duration = g.distribute(qr.duration, 0.5);
  q.minHeroes = g.rnd.nextInt(3)+1;

  return q;
}

List<SkillRequirement> buildSkillRequirements(List<Skill> built, g.Difficulty d) {
  if (built == null) return [];
  return built.map((Skill s) {
    SkillRequirement res = new SkillRequirement()..skill = s;
    int diffIndex = g.Difficulty.difficulties.indexOf(d);
    if (diffIndex == 0) {
      res.difficulty = d;
    } else {
      if (g.rnd.nextDouble() < 0.6) {
        res.difficulty = d;
      } else {
        res.difficulty = g.Difficulty.difficulties[diffIndex-1];
      }
    }
    res.singleHero = (g.rnd.nextDouble() < 0.6);
    return res;

  }).toList();
}

List<QuestRecipe> QUEST_COOKBOOK = null;

void buildQuestCookbook() {
  QUEST_COOKBOOK = [];

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Tresure hunt"
    ..icon = "treasure-map"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
      return merge(allOf(["navigation", "traveling"]), oneOfChildren(["melee", "ranged-combat"]));
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Dragon hunt"
    ..icon = "dragon-head"
    ..money = 1000
    ..experience = 200
    ..duration = 10
    ..builder = () {
      return merge(
          allOf(["melee-heavy", "ranged-combat-heavy"]),
          oneOf(["tactics", "tracking"]),
          oneOf(["magic-atack", "magic-defense"])
      );
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Search and rescue"
    ..icon = "torch"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
      return merge(allOf(["tracking", "pursue"]), oneOfChildren(["melee", "negotiation"]));
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Damsel in distress"
    ..icon = "heart-tower"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
      return merge(allOf(["negotiation", "tactics", "martial-arts"]));
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Competition"
    ..icon = "target-arrows"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
      return merge(
          oneOf(["ranged-combat-bows", "ranged-combat-throw", "melee-sword", "magic"]),
          maybe(oneOf(["tactics","negotiation"]))
      );
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Tournament"
    ..icon = "sword-clash"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
      return merge(
          oneOf(["ranged-combat-bows", "martial-arts", "melee-heavy"]),
          maybe(oneOf(["tactics","negotiation"]))
      );
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Dark lord"
    ..icon = "overlord-helm"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Witness protection"
    ..icon = "shield"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Werewolfs"
    ..icon = "wolf-howl"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Lair"
    ..icon = "cave-entrance"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Catacombs"
    ..icon = "bridge"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Battle"
    ..icon = "spears"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Curse"
    ..icon = "heartburn"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Prison break"
    ..icon = "prisoner"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Plaque"
    ..icon = "dead-head"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Dark secrets"
    ..icon = "shadow-grasp"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

  QUEST_COOKBOOK.add(new QuestRecipe()
    ..name = "Open portal"
    ..icon = "portal"
    ..money = 500
    ..experience = 50
    ..duration = 5
    ..builder = () {
    }
  );

}

List<Skill> maybe(List<Skill> list) {
  if (g.rnd.nextDouble() < 0.5) {
    return list;
  } else {
    return [];
  }
}

List<Skill> allOf(List<String> list) {
  return list.map((String id) => SKILL_CATALOGUE.catalogue[id]).toList();
}

List<Skill> oneOfChildren(List<String> list) {
  List<Skill> candidates = [];
  for (var id in list) {
    candidates.add(SKILL_CATALOGUE.catalogue[id]);
    candidates.addAll(SKILL_CATALOGUE.catalogue[id].children);
  }
  return [g.rndItem(candidates)];
}

List<Skill> oneOf(List<String> list) {
  String one = g.rndItem(list);
  return [SKILL_CATALOGUE.catalogue[one]];
}

List<Skill> merge(List<Skill> a, [List<Skill> b, List<Skill> c, List<Skill> d]) {
  if (a == null) return [];
  if (b == null) return a;
  a.addAll(b);
  if (c != null) a.addAll(c);
  if (d != null) a.addAll(d);
  return a;
}


