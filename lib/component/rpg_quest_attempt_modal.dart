// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/component/rpg_quest_header.dart';
import 'package:rpg_manager/component/rpg_skill.dart';
import 'package:rpg_manager/component/rpg_skill_requirement.dart';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/pipes.dart';

@Component(
    selector: 'rpg-quest-attempt-modal', templateUrl: 'rpg_quest_attempt_modal.html',
    styles: const [
      ":host { display: block;}",
    ],
    directives: const [RpgAttribute, RpgSkill, RpgHero, RpgSkillRequirement, RpgQuestHeader],
    pipes: const [AsBonusPipe, AsPercentPipe]
)
class RpgQuestAttemptModal {

  @Input()
  Quest quest;

  Game game;

  FnxApp app;

  @Output()
  EventEmitter<bool> close = new EventEmitter();

  RpgQuestAttemptModal(this.game, this.app);

  void attempt() {
    print(game.hiredHeroes.where((Hero h) => h.onQuest == quest).toList());
    int diff = quest.minHeroes - game.hiredHeroes.where((Hero h) => h.onQuest == quest).length;
    if (diff > 0) {
      app.alert("Please assign $diff more heroes on this quest.");

    } else {
      game.attemptQuest(quest);
      app.toast("Your heroes left for '${quest.name}'.");
      game.save();
      close.emit(true);
    }
  }

  void requestClose() {
    game.hiredHeroes.forEach((Hero h) { if (h.onQuest == quest) h.onQuest = null;} );
    close.emit(true);
  }

}

