import 'dart:math';

Random rnd = new Random();

const DICE = 10.0;
const AVG = (3.0 * DICE) / 2.0;

double roll() {
  return (rnd.nextDouble() * DICE + rnd.nextDouble() * DICE + rnd.nextDouble() * DICE) - AVG;
}

int rollSkill() {
  return (rnd.nextDouble()*4).round()-2;
}

double rollWithBonus(num bonus) {
  return roll() + bonus;
}

class Roll {

  double value;
  RollResult result;

  Roll.roll(num bonus) {
    value = rollWithBonus(bonus);
    if (value < -11) {
      result = RollResult.FATAL_FAIL;
    } else if (value < 5) {
      result = RollResult.FAIL;
    } else if (value > 11) {
      result = RollResult.FATAL_SUCCESS;
    } else if (value > 5) {
      result = RollResult.SUCCESS;
    } else {
      result = RollResult.AVG;
    }
  }

}

enum RollResult {

  FATAL_FAIL,
  FAIL,
  AVG,
  SUCCESS,
  FATAL_SUCCESS

}