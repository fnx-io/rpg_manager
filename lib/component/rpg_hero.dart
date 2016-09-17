// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_skill.dart';
import 'package:rpg_manager/engine/engine.dart';
import 'package:rpg_manager/engine/commands.dart' as command;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/pipes.dart';

@Component(
    selector: 'rpg-hero', templateUrl: 'rpg_hero.html',
    styles: const [
      ":host { display: block;}",
      ".attribute__bonus { display: inline-block; width: 3em; text-align: left}"
    ],
    directives: const [RpgAttribute, RpgSkill],
    pipes: const [AsBonusPipe]
)
class RpgHero {

  @Input()
  Hero hero;

  @Input()
  Quest quest;

  @Input()
  bool assigned = false;

  @Output()
  EventEmitter<Hero> questAssign = new EventEmitter();

  bool get firePossible => hero.onQuest == null && !assigned;
  bool get questAttempt => quest != null;
  bool get attemptPossible => questAttempt && hero.onQuest == null && !assigned;
  bool get removePossible => questAttempt && assigned;


  String get heroStatus {
    if (hero.onQuest == quest) return "assigned";
    if (hero.onQuest != null) return "on other quest";
    return "available";
  }

  Engine engine;

  FnxApp app;

  RpgHero(this.engine, this.app);

  void hireHero() {
    engine.executeCommand(new command.HireHero(hero));
    app.toast('You hired "${hero.name}" for ${hero.dailySalary}G per day');
  }

  void fireHero() {
    engine.executeCommand(new command.FireHero(hero));
    app.toast('You fired "${hero.name}"');
  }

  void fireQuestAssign() {
    questAssign.emit(hero);
  }

}

