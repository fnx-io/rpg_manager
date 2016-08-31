import 'package:rpg_manager/model/game.dart' as g;
import 'package:rpg_manager/model/skills.dart';
import 'package:angular2/src/facade/lang.dart';

class Hero {

  String name;

  List<HeroAttribute> attributes = [];
  Map<BasicAttribute, HeroAttribute> attributesMap = {};

  List<HeroSkill> skills = [];
  Map<String, HeroSkill> skillMap = {};

  void addAttribute(BasicAttribute attr, int bonus) {
    HeroAttribute ha = new HeroAttribute(this, attr, bonus);
    attributes.add(ha);
    attributesMap[attr] = ha;
  }

  void addSkill(String id, int level) {
    Skill a = SKILL_CATALOGUE.catalogue[id];
    if (a == null) throw "No such skill id=${id}";

    HeroSkill ha = new HeroSkill(this, a, level);
    skills.add(ha);
    skillMap[id] = ha;
  }

  void recountHeroBonuses() {
    for (HeroSkill skill in skills) {
      skill.recountBonus();
    }
  }

}

class HeroAttribute {

  Hero hero;
  BasicAttribute attribute;
  int bonus;

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

  void recountBonus() {
    bonus = skill.countBonusForHero(hero).round();
  }
}

Hero generateHero() {

  void pickRandomSkill(Hero result, List<Skill> from, double trashold) {
    if (trashold < 0.1) return;
    if (from == null || from.isEmpty) return;
    if (result.skills.length >= 3) return;
    var prob = trashold / from.length;
    for (var skill in from) {
      if (g.rnd.nextDouble() < prob) {
        result.addSkill(skill.id, g.rollSkill());
        pickRandomSkill(result, skill.children, trashold / 2);
      }
    }

  }

  Hero result = new Hero();

  BasicAttribute willBeGreatIn = SKILL_CATALOGUE.attributes[g.rnd.nextInt(SKILL_CATALOGUE.attributes.length)];

  for (var a in SKILL_CATALOGUE.attributes) {
    int attrRoll = 0;
    if (a == willBeGreatIn) {
      attrRoll = 2;
    } else {
      attrRoll = g.rollAttribute();
    }
    result.addAttribute(a, attrRoll);
    if (attrRoll == 0) pickRandomSkill(result, a.children, 0.5);
    if (attrRoll == 1) pickRandomSkill(result, a.children, 1.0);
    if (attrRoll >= 2) pickRandomSkill(result, a.children, 2.0);
  }

  result.name = "Franta ${(Math.random() * 100).floor()}";

  result.recountHeroBonuses();

  return result;

}