import 'dart:math';

Random rnd = new Random();

const DICE = 10.0;
const DICE_AVG = (3.0 * DICE) / 2.0;

double roll() {
  return (rnd.nextDouble() * DICE + rnd.nextDouble() * DICE + rnd.nextDouble() * DICE) - DICE_AVG;
}

int rollAttribute() {
  return (rnd.nextDouble()*4).round()-2;
}

int rollSkill() {
  return (rnd.nextDouble()*1).round()+1;
}

Object rndItem(List l) {
  return l[rnd.nextInt(l.length)];
}

RollResult evaluateActionResult(num roll, num bonus) {
  if (roll < -13) return RollResult.FATAL_FAIL;
  if (roll > 13) return RollResult.FATAL_SUCCESS;

  num value = roll + bonus;
  if (value < -11) {
    return RollResult.FATAL_FAIL;
  } else if (value < -5) {
    return RollResult.FAIL;
  } else if (value > 11) {
    return RollResult.FATAL_SUCCESS;
  } else if (value > 5) {
    return RollResult.SUCCESS;
  } else {
    return RollResult.AVG;
  }
}

class RollResult {

  final String name;

  static const RollResult FATAL_FAIL = const RollResult._("fatal failure");
  static const RollResult FAIL = const RollResult._("failure");
  static const RollResult AVG = const RollResult._("average");
  static const RollResult SUCCESS = const RollResult._("success");
  static const RollResult FATAL_SUCCESS = const RollResult._("fatal success");

  const RollResult._(this.name);

  static const results = const [
    RollResult.FATAL_FAIL,
    RollResult.FAIL,
    RollResult.AVG,
    RollResult.SUCCESS,
    RollResult.FATAL_SUCCESS
  ];

}

class Difficulty {

  final int bonus;
  final String name;

  static const Difficulty AVG = const Difficulty._(0, "average");
  static const Difficulty HARD = const Difficulty._(-5, "hard");
  static const Difficulty VERY_HARD = const Difficulty._(-10, "very hard");
  static const Difficulty IMPOSSIBLE = const Difficulty._(-15, "impossible");

  const Difficulty._(this.bonus, this.name);

  static const difficulties = const [
    Difficulty.AVG,
    Difficulty.HARD,
    Difficulty.VERY_HARD,
    Difficulty.IMPOSSIBLE
  ];

}

Map<int, double> PROBABILITY_TABLE = null;

Map<Difficulty,Map<RollResult, double>> buildProbabilityOverview(num bonus) {
  Map<Difficulty,Map<RollResult, double>> result = {};

  result[Difficulty.AVG] = buildProbabilityTable(bonus,Difficulty.AVG);
  result[Difficulty.HARD] = buildProbabilityTable(bonus,Difficulty.HARD);
  result[Difficulty.VERY_HARD] = buildProbabilityTable(bonus,Difficulty.VERY_HARD);
  result[Difficulty.IMPOSSIBLE] = buildProbabilityTable(bonus,Difficulty.IMPOSSIBLE);

  return result;
}


Map<RollResult, double> buildProbabilityTable(num bonus, Difficulty diff) {
  if (PROBABILITY_TABLE == null) {
    PROBABILITY_TABLE = {};
    for (int a=0; a<=10; a++) {
      for (int b=0; b<=10; b++) {
        for (int c=0; c<=10; c++) {
          int res = (a+b+c - DICE_AVG).round();
          if (PROBABILITY_TABLE[res] == null) {
            PROBABILITY_TABLE[res] = 1.0;
          } else {
            PROBABILITY_TABLE[res] = PROBABILITY_TABLE[res] + 1.0;
          }
        }
      }
    }
    for (var o in PROBABILITY_TABLE.keys) {
      PROBABILITY_TABLE[o] = PROBABILITY_TABLE[o]/(pow(DICE+1, 3));
    }
  }

  Map<RollResult, double> probabilityResult = {
    RollResult.FATAL_FAIL: 0.0,
    RollResult.FAIL: 0.0,
    RollResult.AVG: 0.0,
    RollResult.SUCCESS: 0.0,
    RollResult.FATAL_SUCCESS: 0.0
  };

  num modifficator = bonus;
  if (diff != null) {
    modifficator = modifficator + diff.bonus;
  }

  for (var o in PROBABILITY_TABLE.keys) {
    RollResult r = evaluateActionResult(o, modifficator);
    probabilityResult[r] = probabilityResult[r] + PROBABILITY_TABLE[o];
  }
  return probabilityResult;
}

