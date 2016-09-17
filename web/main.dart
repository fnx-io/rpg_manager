// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:fnx_profiler/fnx_profiler.dart';
import 'package:logging/logging.dart';
import 'package:rpg_manager/component/rpg.dart';
import 'package:rpg_manager/engine/engine.dart';
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

  Level currentLoggingLevel = Level.ALL;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    if (rec.level.value > currentLoggingLevel.value) {
      String msg = "${rec.loggerName}: ${rec.level.name}: ${rec.time} ${rec.message} ${rec.error ?? ''}";
      print(msg);
      if (rec.stackTrace != null) {
        print(rec.stackTrace);
      }
    }
  });

  Map cfg = fnxConfig();

  f.App app = f.initializeApp(
      apiKey: cfg["firebase"]["apiKey"],
      authDomain: cfg["firebase"]["authDomain"],
      databaseURL: cfg["firebase"]["databaseURL"],
      storageBucket: cfg["firebase"]["storageBucket"]
  );

  Engine e = new Engine(app);

  bootstrap(RpgMain, [
      ROUTER_PROVIDERS,
      provide(LocationStrategy, useClass: HashLocationStrategy),
      provide(Engine, useValue: e),
      provide(Profiler, useValue: e.profiler)
  ]);
}
