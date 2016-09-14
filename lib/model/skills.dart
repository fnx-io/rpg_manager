import 'package:rpg_manager/model/heroes.dart';

class BasicAttribute {

  String abbr;
  String name;
  int price;
  String description;
  List<Skill> children = [];

  BasicAttribute(this.name, this.price, this.description, this.abbr);

  void addSkill(Skill s) {
    children.add(s);
    s.basedOnAttribute = this;
  }

}
class Skill {

  String abbr;
  String id;
  String name;
  int price;
  String description;

  List<Skill> children = [];

  Skill basedOnSkill = null;
  BasicAttribute basedOnAttribute = null;

  Skill(this.id, this.name, this.price, this.description, [this.abbr]);

  void addSkill(List<Skill> skills) {
    for (var sk in skills) {
      children.add(sk);
      sk.basedOnSkill = this;
    }
  }

  double countBonusForHero(Hero hero) {
    if (hero == null) return -5.0;
    double bonus = 0.0;
    if (hero.skillMap[id] == null) {
      bonus = -5.0;
    } else {
      bonus = hero.skillMap[id].level / 2.0;
    }
    if (basedOnSkill != null) {
      double parentSkillBonus = basedOnSkill.countBonusForHero(hero);
      bonus = bonus + parentSkillBonus;
    } else if (basedOnAttribute != null) {
      bonus = bonus + hero.attributesMap[basedOnAttribute].bonus;
    }
    return bonus;
  }

}

class SkillCatalogue {

  List<Skill> skills = [];
  Map<String, Skill> skillsMap = {};

  Map<String, BasicAttribute> attributesMap = {};
  List<BasicAttribute> attributes = [];

  SkillCatalogue() {
    BasicAttribute strength = new BasicAttribute("Strength", 50, null, "ST");
    registerAttribute(strength);

    BasicAttribute dexterity = new BasicAttribute("Dexterity", 50, null, "DX");
    registerAttribute(dexterity);

    BasicAttribute stamina = new BasicAttribute("Stamina", 50, null, "SM");
    registerAttribute(stamina);

    BasicAttribute intelligence = new BasicAttribute("Intelligence", 50, null, "IN");
    registerAttribute(intelligence);


    strength.addSkill(
        new Skill("melee", "Melee weapons", 20, null)..addSkill([
          new Skill("melee-sword", "Swordsmanship", 20, null),
          new Skill("melee-knife", "Knife fighting", 20, null),
          new Skill("melee-heavy", "Heavy weapons", 20, null)
        ])
    );

    dexterity.addSkill(
        new Skill("ranged-combat", "Ranged combat", 20, null)..addSkill([
          new Skill("ranged-combat-bows", "Bows", 20, null),
          new Skill("ranged-combat-throw", "Throwing", 20, null),
          new Skill("ranged-combat-heavy", "Heavy ranged weapons", 20, null)
        ])
    );
    dexterity.addSkill(new Skill("martial-arts", "Martial arts", 20, null));

    stamina.addSkill(new Skill("traveling", "Traveling", 20, null));
    stamina.addSkill(new Skill("immunity", "Immunity", 20, null));
    stamina.addSkill(new Skill("pursue", "Pursue", 20, null));

    intelligence.addSkill(new Skill("tactics", "Tactics", 20, null));
    intelligence.addSkill(new Skill("navigation", "Navigation", 20, null));
    intelligence.addSkill(new Skill("tracking", "Tracking", 20, null));
    intelligence.addSkill(new Skill("negotiation", "Negotiation", 20, null));

    intelligence.addSkill(
        new Skill("magic", "Magic", 50, null)..addSkill([
          new Skill("magic-atack", "Attack magic", 50, null),
          new Skill("magic-defense", "Defense magic", 50, null),
          new Skill("magic-dark", "Dark magic", 50, null)
        ])
    );

    build();
  }

  void registerSkill(Skill s) {
    if (skillsMap.containsKey(s.id)) throw "There already is an attribute with id=${s.id}";
    skillsMap[s.id] = s;
    skills.add(s);
    for (var ch in s.children) {
      registerSkill(ch);
    }
  }

  void registerAttribute(BasicAttribute a) {
    attributes.add(a);
    attributesMap[a.abbr] = a;
  }

  void build() {
    for (var o in attributes) {
      for (var s in o.children) {
        registerSkill(s);
      }
    }
  }

}