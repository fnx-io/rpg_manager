import 'package:angular2/src/facade/lang.dart';
import 'package:rpg_manager/model/data.dart';
import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/engine/names.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/model/skills.dart';

class Hero extends Entity {

  String name;
  String icon;
  String color;
  int dailySalary = 45;
  int experience = 0;
  int experienceToSpend = 0;
  Quest onQuest = null;
  bool hired = false;
  List<HeroAttribute> attributes = [];
  List<HeroSkill> skills = [];
  bool dead = false;

  Map<BasicAttribute, HeroAttribute> attributesMap = {};
  Map<String, HeroSkill> skillMap = {};


  void addAttribute(BasicAttribute attr, int bonus) {
    HeroAttribute ha = new HeroAttribute(this, attr, bonus);
    attributes.add(ha);
    attributesMap[attr] = ha;
  }

  void addSkill(Skill skill, int level) {
    HeroSkill ha = new HeroSkill(this, skill, level);
    skills.add(ha);
    skillMap[skill.id] = ha;
  }

  void recountHeroBonuses() {
    for (HeroSkill skill in skills) {
      skill.recountBonus();
    }
    dailySalary = skills.map((HeroSkill h) => h.level).reduce((int sum, int el) => sum+el);
  }

  Map toMap() {
    Map result = new Map();
    result["id"] = id;
    result["name"] = name;
    result["icon"] = icon;
    result["color"] = color;
    result["dead"] = dead;
    result["dailySalary"] = dailySalary;
    result["hired"] = hired;
    result["onQuest"] = onQuest?.id;
    result["experience"] = experience;
    result["experienceToSpend"] = experienceToSpend;

    result["attributes"] = attributes.map((HeroAttribute a) {
      return {
        "attribute":a.attribute.abbr,
        "bonus":a.bonus
      };
    }).toList();

    result["skills"] = skills.map((HeroSkill s) {
      return {
        "skill":s.skill.id,
        "level":s.level
      };
    }).toList();
    return result;
  }

  void fromMap(Map m, Game catalogue) {
    id = m["id"];
    name = m["name"];
    icon = m["icon"];
    color = m["color"];
    dead = m["dead"] ?? false;
    experience = m["experience"] ?? 0;
    experienceToSpend = m["experienceToSpend"] ?? 0;
    dailySalary = m["dailySalary"];
    hired = m["hired"];
    onQuest = catalogue.questCatalogue.findById(m["onQuest"]);

    (m["attributes"] as List).forEach((Map m) {
      addAttribute(catalogue.skillCatalogue.attributesMap[m["attribute"]], m["bonus"]);
    });

    (m["skills"] as List).forEach((Map m) {
      addSkill(catalogue.skillCatalogue.findSkillById(m["skill"]), m["level"]);
    });

    recountHeroBonuses();
  }

}

class HeroAttribute {

  Hero hero;
  BasicAttribute attribute;
  int bonus;

  HeroAttribute.empty();

  HeroAttribute(this.hero, this.attribute, this.bonus);


}


class HeroSkill {

  Hero hero;
  Skill skill;
  int level;
  int bonus = 0;

  HeroSkill(this.hero, this.skill, this.level) {
    this.level = level;
  }

  HeroSkill.empty();

  void recountBonus() {
    bonus = skill.countBonusForHero(hero).round();
  }
}

const HERO_COLORS = const [
  "#fff",
  "#e91e63",
  "#9c27b0",
  "#2196f3",
  "#4caf50",
  "#ffeb3b",
  "#607d8b"
];

const HERO_ICONS = const [
  "all-seeing-eye",
  "allied-star",
  "american-shield",
  "anarchy",
  "angel-wings",
  "angry-eyes",
  "animal-skull",
  "batwing-emblem",
  "beams-aura",
  "beer-bottle",
  "beer-stein",
  "bindle",
  "blindfold",
  "bone-gnawer",
  "bordered-shield",
  "branch-arrow",
  "brutal-helm",
  "candle-skull",
  "cartwheel",
  "condor-emblem",
  "condylura-skull",
  "cowled",
  "cracked-helm",
  "crowned-heart",
  "crowned-skull",
  "daggers",
  "death-note",
  "death-skull",
  "death-zone",
  "defibrilate",
  "delighted",
  "desert-skull",
  "diablo-skull",
  "domino-mask",
  "double-face-mask",
  "dread-skull",
  "duality-mask",
  "dwarf-face",
  "eagle-emblem",
  "elephant-head",
  "evil-bat",
  "evil-fork",
  "eye-shield",
  "fanged-skull",
  "farmer",
  "fire-bowl"
];

class HeroesCatalogue extends Catalogue<Hero> {

  Game masterCatalogue;

  HeroesCatalogue(this.masterCatalogue);

}