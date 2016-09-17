// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/component/rpg_quest.dart';
import 'package:rpg_manager/engine/engine.dart';
import 'package:rpg_manager/model/game.dart';

@Component(selector: 'screen-quests', templateUrl: 'screen_quests.html',
    directives: const [RpgHero, RpgAttribute, RpgQuest])
class ScreenQuests {

  @ViewChild(FnxApp)
  FnxApp app;

  Engine engine;
  Game get game => engine.game;

  ScreenQuests(this.app, this.engine);

}
