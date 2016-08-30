Map<String, Skill> catalogue = {};
List<Skill> attributes = [];

class Skill {

  String abbr;
  String id;
  String name;
  int price;
  String description;

  Skill basedOn;
  List<Skill> children = [];

  Skill(this.id, this.name, this.price, this.description) {
    if (catalogue.containsKey(id)) throw "There already is an attribute with id=${id}";
    catalogue[id] = this;
  }

  void addSub(Skill a) {
    children.add(a);
    a.basedOn = this;
  }

}

void buildSkillsCatalogue() {
  Skill strength = new Skill("strength", "Strength", 50, null);
  attributes.add(strength);

  Skill dexterity = new Skill("dexterity", "Dexterity", 50, null);
  attributes.add(dexterity);

  Skill intelligence = new Skill("intelligence", "Intelligence", 50, null);
  attributes.add(intelligence);


}