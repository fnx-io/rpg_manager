// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:rpg_manager/pipes.dart';

@Component(
    selector: 'rpg-skill-requirement', templateUrl: 'rpg_skill_requirement.html',
    styles: const [":host { display: block;}"],
    pipes: const [AsBonusPipe]
)
class RpgSkillRequirement {

  @Input()
  SkillRequirement skillRequirement;

  Skill get skill => skillRequirement.skill;

  FnxApp app;

  RpgSkillRequirement(this.app);

  void showInfo() {
    if (skillRequirement.singleHero) {
      app.alert("Only ONE hero in the party will be tested against this skill. Difficulty is '${skillRequirement.difficulty.name}'.");
    } else {
      app.alert("ALL heroes in the party will be tested against this skill. Difficulty is '${skillRequirement.difficulty.name}'.");
    }
  }

}
