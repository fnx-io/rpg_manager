import 'package:angular2/src/facade/lang.dart';
import 'package:rpg_manager/model/data.dart';
import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/names.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/model/skills.dart';

class Hero extends Entity {

  String name;
  String icon;
  String color;
  int dailySalary = 45;
  Quest onQuest = null;
  bool hired = false;
  List<HeroAttribute> attributes = [];
  List<HeroSkill> skills = [];

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
  }

  Map toMap() {
    Map result = new Map();
    result["id"] = id;
    result["name"] = name;
    result["icon"] = icon;
    result["color"] = color;
    result["dailySalary"] = dailySalary;
    result["hired"] = hired;
    result["onQuest"] = onQuest?.id;

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

  void fromMap(Map m, MasterCatalogue catalogue) {
    id = m["id"];
    name = m["name"];
    icon = m["icon"];
    color = m["color"];
    dailySalary = m["dailySalary"];
    hired = m["hired"];
    onQuest = catalogue.questCatalogue.findById(m["onQuest"]);

    (m["attributes"] as List).forEach((Map m) {
      addAttribute(catalogue.skillCatalogue.attributesMap[m["attribute"]], m["bonus"]);
    });

    (m["skills"] as List).forEach((Map m) {
      addSkill(catalogue.skillCatalogue.skillsMap[m["skill"]], m["level"]);
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

  MasterCatalogue masterCatalogue;

  HeroesCatalogue(this.masterCatalogue);

  void pickRandomSkill(Hero result, List<Skill> from, double trashold) {
    if (trashold < 0.1) return;
    if (from == null || from.isEmpty) return;
    if (result.skills.length >= 3) return;
    var prob = trashold / from.length;
    for (var skill in from) {
      if (g.rnd.nextDouble() < prob) {
        result.addSkill(skill, g.rollSkill());
        pickRandomSkill(result, skill.children, trashold / 2);
      }
    }
  }

  @override
  Hero createNewImpl() {
    Hero result = new Hero();

    SkillCatalogue sc = masterCatalogue.skillCatalogue;

    BasicAttribute willBeGreatIn = sc.attributes[g.rnd.nextInt(sc.attributes.length)];

    for (var a in sc.attributes) {
      int attrRoll = 0;
      if (a == willBeGreatIn) {
        attrRoll = 3;
      } else {
        attrRoll = g.rollAttribute();
      }
      result.addAttribute(a, attrRoll);
      if (attrRoll == 1) pickRandomSkill(result, a.children, 1.0);
      if (attrRoll == 2) pickRandomSkill(result, a.children, 1.5);
      if (attrRoll >= 3) pickRandomSkill(result, a.children, 2.0);
    }

    result.name = generateHeroName();

    result.icon = g.rndItem(HERO_ICONS);
    result.color = g.rndItem(HERO_COLORS);

    result.recountHeroBonuses();

    return result;
  }

}


