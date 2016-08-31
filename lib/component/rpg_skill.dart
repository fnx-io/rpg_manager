// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';
import 'package:rpg_manager/pipes.dart';
import 'package:rpg_manager/rpg_main.dart';

@Component(
    selector: 'rpg-skill', templateUrl: 'rpg_skill.html',
    styles: const [":host { display: block;}"],
    pipes: const [AsBonusPipe]
)
class RpgSkill {

  @Input()
  Skill skill;

  @Input()
  Hero hero;

  HeroSkill get heroSkill => hero == null ? null : hero.skillMap[skill.id];

  RpgMain app;

  RpgSkill(this.app);

  void showInfo() {
    if (hero == null) {
      app.showSkillDetail(skill);
    } else {
      app.showSkillDetail(skill, hero);
    }
  }

}
