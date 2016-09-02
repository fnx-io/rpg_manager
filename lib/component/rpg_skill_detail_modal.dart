// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';
import 'package:rpg_manager/pipes.dart';
import 'package:rpg_manager/rpg_main.dart';

@Component(
    selector: 'rpg-skill-detail-modal', templateUrl: 'rpg_skill_detail_modal.html',
    styles: const [":host { display: block;}"],
    pipes: const [AsBonusPipe, AsPercentPipe]
)
class RpgSkillDetailModal implements OnInit {

  @Input()
  Skill skill;

  @Input()
  Hero hero;

  @Output()
  EventEmitter<bool> close = new EventEmitter();

  HeroSkill get heroSkill => hero == null ? null : hero.skillMap[skill.id];

  Map<g.Difficulty, Map<g.RollResult, double>> probabilities;

  RpgMain app;

  RpgSkillDetailModal(this.app);

  List<g.Difficulty> difficulties = g.Difficulty.difficulties;
  List<g.RollResult> results = g.RollResult.results;

  void requestClose() {
    close.emit(true);
  }

  @override
  ngOnInit() {
    num bonus = skill.countBonusForHero(hero);
    probabilities = g.buildProbabilityOverview(bonus);
  }
}
