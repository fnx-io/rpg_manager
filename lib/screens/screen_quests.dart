// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';

@Component(selector: 'screen-quests', templateUrl: 'screen_quests.html')
class ScreenQuests {

  @ViewChild(FnxApp)
  FnxApp app;

  ScreenQuests(this.app);

}
