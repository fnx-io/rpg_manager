// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/component/rpg.dart';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';

import 'package:rpg_manager/rpg_main.dart';
import 'package:angular2/router.dart';
import 'package:angular2/src/platform/location.dart';
import 'package:firebase3/firebase.dart' as f;
import 'package:fnx_config/fnx_config_read.dart';

main() {

  Map cfg = fnxConfig();

  f.initializeApp(
      apiKey: cfg["firebase"]["apiKey"],
      authDomain: cfg["firebase"]["authDomain"],
      databaseURL: cfg["firebase"]["databaseURL"],
      storageBucket: cfg["firebase"]["storageBucket"]
  );

  f.Database database = f.database();

  Game game = new Game(database);

  bootstrap(RpgMain, [
      ROUTER_PROVIDERS,
      provide(LocationStrategy, useClass: HashLocationStrategy),
      provide(Game, useValue: game),
      provide(f.Database, useValue: database)
  ]);
}
