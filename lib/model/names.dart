import 'package:rpg_manager/model/dice.dart' as g;

var VOWELS = ["a", "e", "i", "o", "u", "y"];
var CONSONANTS = ["b", "c", "d", "g", "h", "j", "k", "l", "m", "n", "p", "r", "s", "t", "v", "z" ];
var CONSONANTS_RARE = ["q", "x", "w", "f"];

var COMMON_ENDING = ["rin", "del", "dil", "son", "oin", "ur", "alf", "boy", "sko", "bot", "bil", "lis", "rion"];

var PLACE_NAME_END = ["berg", "pond", "way", "burg", "stein", "castle", "hall", "fall", "witch", "creek", "mill", "court", "field", "port", "town", "dor", "cross"];
var PLACE_NAME_BEGIN = ["Red", "Blue", "Green", "River", "Hollow", "Shadow", "Rose",
"New", "Bitter", "Nor", "White", "Black", "Old", "Dragon", "Hell", "Fairy", "Elven", "High", "Low"];

String generatePlaceName() {
  String name = "${g.rndItem(PLACE_NAME_BEGIN)}${g.rndItem(PLACE_NAME_END)}";
  name = name.replaceAll("ww", "w");
  return name;
}

String generateHeroName() {
  double prob = 1.2;
  List<String> name = [];
  while (g.rnd.nextDouble() < prob) {
    prob = prob - 0.1;
    name.add(generateRandomSegment(name));
  }
  if (name.length <=5) {
    name.add(g.rndItem(COMMON_ENDING));
  }

  if (g.rnd.nextDouble()<0.35) {
    name.add(" ");
    double prob = 1.3;
    while (g.rnd.nextDouble() < prob && prob > 0.8) {
      prob = prob - 0.1;
      name.add(generateRandomSegment(name));
    }
    name.add(g.rndItem(COMMON_ENDING));
  }

  return name.join("");
}

String generateRandomSegment(List<String> name) {
  List<String> toChooseFrom = null;
  bool upper = false;
  if (name.length == 0) {
    upper = true;
  }
  if (name.length == 0) {
    if (g.rnd.nextDouble()<0.2) {
      toChooseFrom = VOWELS;
    } else {
      toChooseFrom = CONSONANTS;
    }
  } else {
    String last = name.last;
    if (last == " ") upper = true;
    if (CONSONANTS.contains(last.toLowerCase()) || CONSONANTS_RARE.contains(last.toLowerCase())) {
      toChooseFrom = VOWELS;
    } else {
      if (g.rnd.nextDouble() < 0.01) {
        toChooseFrom = CONSONANTS_RARE;
      } else {
        toChooseFrom = CONSONANTS;
      }
    }
  }
  String res = g.rndItem(toChooseFrom);
  if (upper) {
    res = res.toUpperCase();
  } else if (g.rnd.nextDouble() < 0.001) {
    res = res+res;
  }
  return res;
}