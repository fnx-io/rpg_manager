// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
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

  Engine engine;

  List<Hero> assignedHeroes = [];

  FnxApp app;

  @Output()
  EventEmitter<bool> close = new EventEmitter();

  RpgQuestAttemptModal(this.engine, this.app);

  void assignHero(Hero h) {
    if (assignedHeroes.contains(h)) {
      assignedHeroes.remove(h);
    } else {
      assignedHeroes.add(h);
    }
  }

  void attempt() {
    int diff = quest.minHeroes - assignedHeroes.length;
    if (diff > 0) {
      app.alert("Please assign $diff more heroes on this quest.");

    } else {
      engine.executeCommand(new command.AttemptQuest(quest, assignedHeroes));
      app.toast("Your heroes left for '${quest.name}'.");
      close.emit(true);
    }
  }

  void requestClose() {
    assignedHeroes = [];
    close.emit(true);
  }

}

