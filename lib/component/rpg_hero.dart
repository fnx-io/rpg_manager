// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_skill.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';
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

  RpgHero() {
  }

  String briefAttributes() {
    return hero.attributes.map((HeroAttribute s) => s.attribute.abbr + (s.bonus >= 0 ? '+' : '') + s.bonus.toString()).join(", ");
  }

}

