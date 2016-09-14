// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:fnx_ui/fnx_ui.dart';

@Component(selector: 'screen-items', templateUrl: 'screen_items.html')
class ScreenItems {

  @ViewChild(FnxApp)
  FnxApp app;

  ScreenItems(this.app);

}
