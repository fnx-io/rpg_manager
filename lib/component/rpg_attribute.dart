// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';
import 'package:rpg_manager/pipes.dart';

@Component(
    selector: 'rpg-attribute', templateUrl: 'rpg_attribute.html',
    styles: const [":host { display: block;}"],
    pipes: const [AsBonusPipe]
)
class RpgAttribute {

  @Input()
  BasicAttribute attribute;

  @Input()
  Hero hero;

  HeroAttribute get heroAttribute => hero == null ? null : hero.attributesMap[attribute];

  FnxApp app;

  RpgAttribute(this.app);

  void showInfo() {
    if (hero == null) {
      app.alert("${attribute.name} is a very important attribute of your heroes!");
    } else {
      app.alert("${hero.name} has a bonus ${heroAttribute.bonus >= 0 ? '+' : ''}${heroAttribute.bonus} on skills based on ${attribute.name}.");
    }
  }

}
