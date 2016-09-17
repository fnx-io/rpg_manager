part of commands;

class GenerateHero extends Command<Hero> {

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
  Hero execute(Engine e) {
    Hero result = new Hero();

    SkillCatalogue sc = e.game.skillCatalogue;

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

    e.game.heroesCatalogue.registerNew(result);

    return result;
  }

}

class HireHero extends Command<Hero> {

  Hero h;

  HireHero(this.h);

  @override
  Hero execute(Engine e) {
    assert(!h.dead);
    h.hired = true;
    return h;
  }
}

class FireHero extends Command<Hero> {

  Hero h;

  FireHero(this.h);

  @override
  Hero execute(Engine e) {
    assert(!h.dead);
    h.hired = false;
    return h;
  }

}