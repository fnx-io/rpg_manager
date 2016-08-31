// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/component/rpg_skill.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:rpg_manager/screens/screen_heroes.dart';
import 'package:rpg_manager/screens/screen_home.dart';
import 'package:rpg_manager/screens/screen_items.dart';
import 'package:rpg_manager/screens/screen_quests.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

@Component(
    selector: 'rpg-main', templateUrl: 'rpg_main.html',
    directives: const [RpgAttribute, RpgSkill],
    pipes: const [AsBonusPipe]
)
@RouteConfig(const [
  const Route(path: "/Home", name: "Home", component: ScreenHome, useAsDefault: true),
  const Route(path: "/Heroes", name: "Heroes", component: ScreenHeroes),
  const Route(path: "/Quests", name: "Quests", component: ScreenQuests),
  const Route(path: "/Items", name: "Items", component: ScreenItems)
])
class RpgMain implements AfterViewInit {

  @ViewChild(FnxApp)
  FnxApp app;

  RpgMain();

  @override
  ngAfterViewInit() {
    app.toast("Hej!");
  }

  Skill skillToShow;
  Hero heroToShow;

  void closeSkillDetail() {
    skillToShow = null;
    heroToShow = null;
  }

  void showSkillDetail(Skill s, [Hero h]) {
    skillToShow = s;
    heroToShow = h;
  }

}
