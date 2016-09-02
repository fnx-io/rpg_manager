// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/component/rpg_skill.dart';
import 'package:rpg_manager/component/rpg_skill_requirement.dart';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/pipes.dart';

@Component(
    selector: 'rpg-quest', templateUrl: 'rpg_quest.html',
    styles: const [
      ":host { display: block;}",
    ],
    directives: const [RpgAttribute, RpgSkill, RpgHero, RpgSkillRequirement],
    pipes: const [AsBonusPipe, AsPercentPipe]
)
class RpgQuest {

  @Input()
  Quest quest;

  double get progress => quest.progress(game.currentTime);

  Game game;

  FnxApp app;

  RpgQuest(this.game, this.app);

  void deleteQuest() {
    game.availableQuests.remove(quest);
  }

  void attemptQuest() {
    game.attemptQuest(quest);
    if (true) return;
    if (game.hiredHeroes.isEmpty) {
      app.alert("You need to hire some heroes first.");
    } else {
      game.attemptQuest(quest);
      app.toast("Your heroes left for '${quest.name}'.");
    }
  }

}

