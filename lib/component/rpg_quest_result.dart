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
import 'package:rpg_manager/model/engine.dart';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/pipes.dart';

@Component(
    selector: 'rpg-quest-result', templateUrl: 'rpg_quest_result.html',
    styles: const [
      ":host { display: block;}",
    ],
    directives: const [RpgAttribute, RpgSkill, RpgHero, RpgSkillRequirement, RpgQuestHeader, RpgQuestAttemptModal],
    pipes: const [AsBonusPipe, AsPercentPipe]
)
class RpgQuestResult {

  @Input()
  QuestResult questResult;

  Game game;

  FnxApp app;

  RpgQuestResult(this.game, this.app);

  void closeResult() {
    game.masterCatalogue.questCatalogue.remove(questResult.quest);
    game.questResults.remove(questResult);
  }

}