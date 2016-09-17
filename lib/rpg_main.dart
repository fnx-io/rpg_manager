// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:firebase3/firebase.dart';
import 'package:fnx_profiler/fnx_profiler.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_skill.dart';
import 'package:rpg_manager/engine/engine.dart';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/pipes.dart';
import 'package:rpg_manager/screens/screen_heroes.dart';
import 'package:rpg_manager/screens/screen_home.dart';
import 'package:rpg_manager/screens/screen_items.dart';
import 'package:rpg_manager/screens/screen_login.dart';
import 'package:rpg_manager/screens/screen_quests.dart';

@Component(
    selector: 'rpg-main', templateUrl: 'rpg_main.html',
    directives: const [RpgAttribute, RpgSkill, ScreenLogin],
    pipes: const [AsBonusPipe, AsPercentPipe, AsDatePipe]
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

  ApplicationRef appRef;

  Engine engine;
  Game get game => engine.game;
  Profiler profiler;

  RpgMain(this.engine, this.appRef, this.profiler) {
    engine.events.listen(engineEventsHandler);
  }

  void engineEventsHandler(EngineEvent e) {
    if (e.type == EngineEventType.NEW_HERO) {
      //app.toast("New hero is available: ${(e.param as Hero).name}");
    }
    if (e.type == EngineEventType.NEW_QUEST) {
      //app.toast("New quest is available: ${(e.param as Quest).name}");
    }
    if (e.type == EngineEventType.TICK) {
      // detect changes with each tick, some time-related changes are not detected
      Profiler child = profiler.openChild("tick");
      appRef.tick();
      child.close();
    }
    if (e.type == EngineEventType.HERO_LEFT) {
      app.toast("You didn't have enough money to pay ${(e.param as Hero).name}. Hero left you.");
    }
  }

  @override
  void ngAfterViewInit() {
  }

}