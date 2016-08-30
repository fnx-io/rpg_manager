// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';

@Component(
    selector: 'screen-heroes',
    templateUrl: 'screen_heroes.html',
    directives: const [RpgHero, RpgAttribute]
)
class ScreenHeroes {

  @ViewChild(FnxApp)
  FnxApp app;

  List<Hero> heroesToHire = [];

  ScreenHeroes(this.app) {
    for (int a=0; a<20;a++) {
      heroesToHire.add(generateHero());
    }
  }

}
