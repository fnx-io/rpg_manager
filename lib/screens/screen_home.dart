// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/model/game.dart' as g;
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';

@Component(selector: 'screen-home', templateUrl: 'screen_home.html')
class ScreenHome {

  @ViewChild(FnxApp)
  FnxApp app;

  List list = [];

  ScreenHome(this.app) {
    for (int a=0; a<100;a++) {
      list.add(g.roll().round());
    }
    list.sort();
  }



}
