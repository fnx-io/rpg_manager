// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/component/rpg_quest_attempt_modal.dart';
import 'package:rpg_manager/component/rpg_quest_header.dart';
import 'package:rpg_manager/component/rpg_skill.dart';
import 'package:rpg_manager/component/rpg_skill_requirement.dart';
import 'package:rpg_manager/engine/engine.dart';
import 'package:rpg_manager/engine/commands.dart' as command;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/pipes.dart';

@Component(
    selector: 'rpg-quest', templateUrl: 'rpg_quest.html',
    styles: const [
      ":host { display: block;}",
    ],
    directives: const [RpgAttribute, RpgSkill, RpgHero, RpgSkillRequirement, RpgQuestHeader, RpgQuestAttemptModal],
    pipes: const [AsBonusPipe, AsPercentPipe]
)
class RpgQuest {

  @Input()
  Quest quest;

  double get progress => quest.progress(engine.game.currentTime);

  Engine engine;

  FnxApp app;

  bool showAttemptModal = false;

  String get skills => quest.requiredSkills.map((SkillRequirement r) => r.skill.name).join(", ");

  RpgQuest(this.engine, this.app);

  void deleteQuest() {
    engine.executeCommand(new command.DeleteQuest(quest));
  }

  void attemptQuest() {
    if (engine.game.hiredHeroes.isEmpty) {
      app.alert("You need to hire some heroes first.");

    } else if (engine.game.hiredHeroes.where((Hero h) => h.onQuest == null).length < quest.minHeroes) {
      app.alert("You don't have enough heroes to attempt this quest.");

    } else {
      showAttemptModal = true;
    }
  }

  Iterable<Hero> get heroesOnQuest {
    return engine.game.heroesCatalogue.all.where((Hero h) => h.onQuest == quest);
  }

}