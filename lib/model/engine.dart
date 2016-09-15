import 'dart:async';

import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';

const int TIME_SCALE = 24 * 60;//(24 * 60 * 60 / 60; // one minute is one day
const int TICK_MS = 4321; // tick every X ms
const Duration SCALED_TICK_DURATION = const Duration(milliseconds: TICK_MS * TIME_SCALE );

const double DEFAULT_QUEST_IN_TICK_PROBABILITY = 0.02;
const double DEFAULT_HERO_IN_TICK_PROBABILITY = 0.01;

class Engine {

  Game game;

  Stream<EngineEvent> events;
  StreamController<EngineEvent> _controller = new StreamController();

  double questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
  double heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;

  Engine(this.game) {
    _controller = new StreamController();
    events = _controller.stream;
  }

  void start() {
    Timer tickGenerator = new Timer.periodic(new Duration(milliseconds: TICK_MS), doTick);
  }

  void doTick(Timer timer) {

    bool dryRun = game.loggedUser == null;

    int day = game.currentTime.day;
    game.currentTime = game.currentTime.add(SCALED_TICK_DURATION);

    if (day != game.currentTime.day) {
      _controller.sink.add(new EngineEvent(EngineEventType.NEW_DAY));

      int payday = game.hiredHeroes.map((Hero h) => h.dailySalary).reduce((int sum, int salary) => sum+salary);
      game.money -= payday;

      game.save();
    }
    if (!dryRun) {
      if (game.availableQuests.length < 20) {
        if (g.rnd.nextDouble() < questProbability) {
          Quest q = game.masterCatalogue.questCatalogue.createNew();
          _controller.sink.add(new EngineEvent(EngineEventType.NEW_QUEST, q));
          game.save();
          questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
        } else {
          questProbability = questProbability * 1.2;
        }
      }
      if (game.heroesToHire.length < 20) {
        if (g.rnd.nextDouble() < heroProbability) {
          Hero h = game.masterCatalogue.heroesCatalogue.createNew();
          _controller.sink.add(new EngineEvent(EngineEventType.NEW_HERO, h));
          game.save();
          heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;
        } else {
          heroProbability = heroProbability * 1.2;
        }
      }
    }

    game.questsInProgress.where((Quest q) => q.progress(game.currentTime) >= 1).forEach((Quest q) {
      print(q.name + " has finished");
      evaluateQuestResult(q);
    });

    _controller.sink.add(new EngineEvent(EngineEventType.TICK));
  }

  void evaluateQuestResult(Quest q) {

    QuestResult questResult = new QuestResult();
    questResult.quest = q;

    Iterable<Hero> heroesOnQuest = game.hiredHeroes.where((Hero h) => h.onQuest == q);

    var notDead = ((Hero h) => !h.dead);

    q.requiredSkills.forEach((SkillRequirement s) {
      if (s.singleHero) {
        // find the best hero
        Hero best = heroesOnQuest.where(notDead).reduce((Hero best, Hero current) {
          if (s.skill.countBonusForHero(current) > s.skill.countBonusForHero(best)) {
            return current;
          } else {
            return best;
          }
        });
        questResult.results.add(evaluateHeroAttempt(best, s));

      } else {
        heroesOnQuest.where(notDead).forEach(
            (Hero h) => questResult.results.add(evaluateHeroAttempt(h, s))
        );
      }
    });

    final int sum = questResult.results.map((HeroSkillAttemptResult res) => res.result.id).reduce((int sum, int val) => sum + val);
    int cnt = questResult.results.length;
    int avg = (sum / cnt).round();

    if (sum > 0) {
      questResult.results.forEach((HeroSkillAttemptResult res) {
        res.experience = (q.experience * res.result.id / sum).round();
      });
    }

    g.RollResult overall = g.RollResult.findById(avg);
    questResult.overallResult = overall;

    print("Overall quest result ${overall}");

    game.questResults.add(questResult);
    _controller.sink.add(new EngineEvent(EngineEventType.QUEST_FINISHED, questResult));

    //dsadsadasda // overal, prachy, expy
  }

  HeroSkillAttemptResult evaluateHeroAttempt(Hero h, SkillRequirement s) {
    assert(!h.dead);
    double bonus = s.skill.countBonusForHero(h) + s.difficulty.bonus;
    g.RollResult result = g.evaluateActionResult(g.roll(), bonus);
    print("${h.name} attempted ${s.skill.name} (diff=${s.difficulty.bonus}) with bonus ${s.skill.countBonusForHero(h)} (sum=$bonus), with result: ${result.name}");

    if (result == g.RollResult.FATAL_FAIL) {
      // h.dead = true;
    }

    return new HeroSkillAttemptResult()
        ..skillRequirement = s
        ..result = result
        ..hero = h;
  }

}

class HeroSkillAttemptResult {

  Hero hero;
  SkillRequirement skillRequirement;
  g.RollResult result;
  int experience = 0;

}

class QuestResult {

  Quest quest;
  g.RollResult overallResult;
  int money = 0;
  List<HeroSkillAttemptResult> results = [];

}

enum EngineEventType {
  TICK, NEW_DAY, NEW_QUEST, NEW_HERO, QUEST_FINISHED
}

class EngineEvent {

  EngineEventType type;
  Object param;

  EngineEvent(this.type, [this.param]);

}
