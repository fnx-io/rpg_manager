import 'package:rpg_manager/model/game.dart' as g;
import 'package:rpg_manager/model/skills.dart';
import 'package:angular2/src/facade/lang.dart';

class Hero {

  String name;

  List<HeroSkill> attributes = [];
  List<HeroSkill> skills = [];

  void addSkill(String id, int bonus) {
    Skill a = catalogue[id];
    if (a == null) throw "No such attribute id=${id}";
    HeroSkill ha = new HeroSkill(a, bonus);
    if (a.basedOn == null) {
      attributes.add(ha);
    } else {
      skills.add(ha);
    }
  }

}

class HeroSkill {

  Skill skill;
  int bonus;

  HeroSkill(this.skill, this.bonus);

}

Hero generateHero() {

  Hero result = new Hero();
  result.addSkill("strength", g.rollSkill());
  result.addSkill("dexterity", g.rollSkill());
  result.addSkill("intelligence", g.rollSkill());
  result.name = "Franta ${(Math.random() * 100).floor()}";
  return result;

}