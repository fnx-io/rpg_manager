import 'package:rpg_manager/model/data.dart';
import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/names.dart';
import 'package:rpg_manager/model/skills.dart';

typedef List<Skill> RequestedSkillsBuilder();

class QuestRecipe {

  int id;
  String name;
  String description;
  String icon;
  int money;
  int experience;
  int duration = 1;
  RequestedSkillsBuilder builder;

}

class Quest extends Entity {

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

  Map toMap() {
    Map result = new Map();

    result["id"] = id;
    result["name"] = name;
    result["overallDifficulty"] = overallDifficulty.name;
    result["recipe"] = recipe.id;
    result["money"] = money;
    result["experience"] = experience;
    result["duration"] = duration;
    result["minHeroes"] = minHeroes;
    result["started"] = started?.millisecondsSinceEpoch;
    result["finish"] = finish?.millisecondsSinceEpoch;

    result["requiredSkills"] = requiredSkills.map((SkillRequirement r) {
      return {
        "skill":r.skill.id,
        "singleHero":r.singleHero,
        "difficulty":r.difficulty.name
      };
    }).toList();

    return result;
  }

  void fromMap(Map m, MasterCatalogue masterCatalogue) {
    id = m["id"];
    name = m["name"];
    overallDifficulty = g.Difficulty.findByName(m["overallDifficulty"]);
    recipe = masterCatalogue.questCatalogue.findQuestRecipeById(m["recipe"]);
    money = m["money"];
    experience = m["experience"];
    duration = m["duration"];
    minHeroes = m["minHeroes"];
    if (m["started"] != null) {
      started = new DateTime.fromMillisecondsSinceEpoch(m["started"]);
    }
    if (m["finish"] != null) {
      finish = new DateTime.fromMillisecondsSinceEpoch(m["finish"]);
    }

    if (m["requiredSkills"] != null) {
      (m["requiredSkills"] as List).forEach((Map s) {
        SkillRequirement sk = new SkillRequirement();
        sk.difficulty = g.Difficulty.findByName(s["difficulty"]);
        sk.singleHero = s["singleHero"];
        sk.skill = masterCatalogue.skillCatalogue.skillsMap[s["skill"]];
        requiredSkills.add(sk);
      });
    }
  }
}

class SkillRequirement {

  Skill skill;
  bool singleHero;
  g.Difficulty difficulty;

}


class QuestCatalogue extends Catalogue<Quest> {

  List<QuestRecipe> questRecipes = [];
  MasterCatalogue masterCatalogue;

  QuestCatalogue(this.masterCatalogue) {
    questRecipes.add(new QuestRecipe()
      ..id = 1
      ..name = "Tresure hunt"
      ..icon = "treasure-map"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {
        return merge(allOf(["navigation", "traveling"]), oneOfChildren(["melee", "ranged-combat"]));
      }
    );

    questRecipes.add(new QuestRecipe()
      ..id = 2
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

    questRecipes.add(new QuestRecipe()
      ..id = 3
      ..name = "Search and rescue"
      ..icon = "torch"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {
        return merge(allOf(["tracking", "pursue"]), oneOfChildren(["melee", "negotiation"]));
      }
    );

    questRecipes.add(new QuestRecipe()
      ..id = 4
      ..name = "Damsel in distress"
      ..icon = "heart-tower"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {
        return merge(allOf(["negotiation", "tactics", "martial-arts"]));
      }
    );

    questRecipes.add(new QuestRecipe()
      ..id = 5
      ..name = "Competition"
      ..icon = "target-arrows"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {
        return merge(
            oneOf(["ranged-combat-bows", "ranged-combat-throw", "melee-sword", "magic"]),
            maybe(oneOf(["tactics", "negotiation"]))
        );
      }
    );

    questRecipes.add(new QuestRecipe()
      ..id = 6
      ..name = "Tournament"
      ..icon = "sword-clash"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {
        return merge(
            oneOf(["ranged-combat-bows", "martial-arts", "melee-heavy"]),
            maybe(oneOf(["tactics", "negotiation"]))
        );
      }
    );

    questRecipes.add(new QuestRecipe()
      ..id = 7
      ..name = "Dark lord"
      ..icon = "overlord-helm"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 8
      ..name = "Witness protection"
      ..icon = "shield"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 9
      ..name = "Werewolfs"
      ..icon = "wolf-howl"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 10
      ..name = "Lair"
      ..icon = "cave-entrance"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 11
      ..name = "Catacombs"
      ..icon = "bridge"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 12
      ..name = "Battle"
      ..icon = "spears"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 13
      ..name = "Curse"
      ..icon = "heartburn"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 14
      ..name = "Prison break"
      ..icon = "prisoner"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 15
      ..name = "Plaque"
      ..icon = "dead-head"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 16
      ..name = "Dark secrets"
      ..icon = "shadow-grasp"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );

    questRecipes.add(new QuestRecipe()
      ..id = 17
      ..name = "Open portal"
      ..icon = "portal"
      ..money = 500
      ..experience = 50
      ..duration = 5
      ..builder = () {}
    );
  }

  QuestRecipe findQuestRecipeById(int id) {
    return questRecipes.firstWhere((QuestRecipe qr) => qr.id == id);
  }

  List<SkillRequirement> generateSkillRequirements(List<Skill> built, g.Difficulty d) {
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

    }).toList() as List<SkillRequirement>;
  }

  List<Skill> maybe(List<Skill> list) {
    if (g.rnd.nextDouble() < 0.5) {
      return list;
    } else {
      return [];
    }
  }

  List<Skill> allOf(List<String> list) {
    return list.map((String id) => masterCatalogue.skillCatalogue.skillsMap[id]).toList() as List<Skill>;
  }

  List<Skill> oneOfChildren(List<String> list) {
    List<Skill> candidates = [];
    for (var id in list) {
      candidates.add(masterCatalogue.skillCatalogue.skillsMap[id]);
      candidates.addAll(masterCatalogue.skillCatalogue.skillsMap[id].children);
    }
    return [g.rndItem(candidates)];
  }

  List<Skill> oneOf(List<String> list) {
    String one = g.rndItem(list);
    return [masterCatalogue.skillCatalogue.skillsMap[one]];
  }

  List<Skill> merge(List<Skill> a, [List<Skill> b, List<Skill> c, List<Skill> d]) {
    if (a == null) return [];
    if (b == null) return a;
    a.addAll(b);
    if (c != null) a.addAll(c);
    if (d != null) a.addAll(d);
    return a;
  }

  @override
  Quest createNewImpl() {
    QuestRecipe qr = g.rndItem(questRecipes);
    g.Difficulty d = g.rndItem(g.Difficulty.difficulties);

    Quest q = new Quest();
    q.overallDifficulty = d;
    q.recipe = qr;
    q.name = qr.name + " at " + generatePlaceName();
    q.requiredSkills = generateSkillRequirements(qr.builder(), d);
    q.money = (qr.money * d.rewardCoeficient).round();
    q.experience = (qr.experience * d.rewardCoeficient).round();
    q.duration = g.distribute(qr.duration, 0.5);
    q.minHeroes = g.rnd.nextInt(3)+1;

    return q;
  }

}


