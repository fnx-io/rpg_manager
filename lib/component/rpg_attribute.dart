// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:angular2/core.dart';

@Component(
    selector: 'rpg-attribute', templateUrl: 'rpg_attribute.html',
    styles: const [":host { display: block;}"]
)
class RpgAttribute {

  @Input()
  Skill attribute;

  @Input()
  int bonus;

  FnxApp app;

  RpgAttribute(this.app);

  void showInfo() {
    app.toast("Huhle!");
  }

}
