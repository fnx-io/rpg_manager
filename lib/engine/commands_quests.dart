part of commands;

class AttemptQuest extends Command<Quest> {

  Quest q;
  List<Hero> heroes;

  AttemptQuest(this.q, this.heroes);

  @override
  Quest execute(Engine e) {
    assert(heroes.length >= q.minHeroes);
    assert(e.game.questCatalogue.findById(q.id)==q);
    assert(q.started == null);
    heroes.forEach((Hero h) {
      assert(h.onQuest == null);
      assert(!h.dead);
      assert(h.hired);
      h.onQuest = q;
    });
    q.started = e.game.currentTime;
    q.finish = q.started.add(new Duration(days: q.duration));
    e.save();
    return q;
  }

}

class GenerateNewQuest extends Command<Quest> {

  g.Difficulty difficulty;

  GenerateNewQuest([this.difficulty]);

  @override
  Quest execute(Engine e) {
    List<SkillRequirement> generateSkillRequirements(List<Skill> built, g.Difficulty d) {
      return built.map((Skill s) {
        if (s == null) throw "Null skill requirement in quest";
        SkillRequirement res = new SkillRequirement()..skill = s;
        int diffIndex = g.Difficulty.difficulties.indexOf(d);
        if (diffIndex == 0) {
          res.difficulty = d;
        } else {
          if (g.rnd.nextDouble() < 0.6) {
            res.difficulty = d;
          } else {
            res.difficulty = g.Difficulty.difficulties[diffIndex-1];
          }
        }
        res.singleHero = (g.rnd.nextDouble() < 0.6);
        return res;

      }).toList();
    }

    List<QuestRecipe> questRecipes = e.game.questCatalogue.questRecipes;
    QuestRecipe qr = g.rndItem(questRecipes);
    g.Difficulty d = difficulty ?? g.rndItem(g.Difficulty.difficulties);
    if (qr.builder() == null) {
      throw "Quest recipe ${qr.name} has no regired skill builder";
    }

    Quest q = new Quest();
    q.overallDifficulty = d;
    q.recipe = qr;
    q.name = qr.name + " at " + generatePlaceName();
    q.requiredSkills = generateSkillRequirements(qr.builder(), d);
    q.money = (qr.money * d.rewardCoeficient).round();
    q.experience = (qr.experience * d.rewardCoeficient).round();
    q.duration = g.distribute(qr.duration, 0.5);
    q.minHeroes = g.rnd.nextInt(3)+1;

    e.game.questCatalogue.registerNew(q);

    return q;
  }
}

class DeleteQuest extends Command<Quest> {

  Quest q;

  DeleteQuest(this.q);

  @override
  Quest execute(Engine e) {
    assert(q.started == null || q.result != null);
    e.game.questCatalogue.remove(q);
    if (q.result != null) {
      e.game.questResults.remove(q.result);
    }
  }
}

class EvaluateQuestResult extends Command<QuestResult> {

  Quest q;

  EvaluateQuestResult(this.q);

  @override
  QuestResult execute(Engine e) {
    assert(e.game.currentTime.isAfter(q.finish));

    QuestResult questResult = new QuestResult();
    questResult.quest = q;

    Iterable<Hero> heroesOnQuest = e.game.hiredHeroes.where((Hero h) => h.onQuest == q);

    var notDead = ((Hero h) => !h.dead);

    q.requiredSkills.forEach((SkillRequirement s) {
      if (s.singleHero) {
        // find the best hero
        if (heroesOnQuest
            .where(notDead)
            .isNotEmpty) {
          Hero best = heroesOnQuest.where(notDead).reduce((Hero best, Hero current) {
            if (s.skill.countBonusForHero(current) > s.skill.countBonusForHero(best)) {
              return current;
            } else {
              return best;
            }
          });
          questResult.results.add(evaluateHeroAttempt(e.game, best, s));
        }
      } else {
        heroesOnQuest.where(notDead).forEach(
            (Hero h) => questResult.results.add(evaluateHeroAttempt(e.game, h, s))
        );
      }
    });

    int sum = 0;
    if (questResult.results.isNotEmpty) {
      sum = questResult.results.map((HeroSkillAttemptResult res) => res.result.id).reduce((int sum, int val) => sum + val);
    }
    int cnt = questResult.results.length;
    int avg = cnt == 0 ? 0 : (sum / cnt).round();

    g.RollResult overall = g.RollResult.findById(avg);
    questResult.overallResult = overall;

    print("Overall quest result ${overall}");

    double resultMoney = 0.0;
    double resultExperience = 0.0;

    switch (overall) {
      case g.RollResult.FATAL_FAIL:
        resultMoney = 0.0;
        resultExperience = q.experience * 0.2;
        break;
      case g.RollResult.FAIL:
        resultMoney = 0.0;
        resultExperience = q.experience * 0.5;
        break;
      case g.RollResult.AVG:
        resultMoney = q.money * 0.7;
        resultExperience = q.experience * 1.0;
        break;
      case g.RollResult.SUCCESS:
        resultMoney = q.money * 1.0;
        resultExperience = q.experience * 1.2;
        break;
      case g.RollResult.FATAL_SUCCESS:
        resultMoney = q.money * 1.5;
        resultExperience = q.experience * 2.0;
        break;
    }

    questResult.money = resultMoney.round();

    if (sum > 0) {
      questResult.results.forEach((HeroSkillAttemptResult res) {
        res.experience = (resultExperience * res.result.id / sum).round();
        res.hero.experience += res.experience;
        res.hero.experienceToSpend += res.experience;
      });
    }

    e.game.questResults.add(questResult);

    q.result = questResult;
    e.game.money += questResult.money.round();
    heroesOnQuest.forEach((Hero h) => h.onQuest = null);

    e.game.hiredHeroes.where((Hero h) => h.dead).forEach((Hero h) {
       new Future.microtask(() => e.game.heroesCatalogue.remove(h));
    });
    e.game.questCatalogue.remove(q);

    e.save();
    return questResult;
  }

  HeroSkillAttemptResult evaluateHeroAttempt(Game game, Hero h, SkillRequirement s) {
    assert(!h.dead);
    double bonus = s.skill.countBonusForHero(h) + s.difficulty.bonus;
    g.RollResult result = g.evaluateActionResult(g.roll(), bonus);
    print("${h.name} attempted ${s.skill.name} (diff=${s.difficulty.bonus}) with bonus ${s.skill.countBonusForHero(h)} (sum=$bonus), with result: ${result.name}");

    if (result == g.RollResult.FATAL_FAIL) {
      h.dead = true;
    }

    return new HeroSkillAttemptResult()
      ..skillRequirement = s
      ..result = result
      ..hero = h;
  }

}