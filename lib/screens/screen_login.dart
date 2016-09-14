// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:firebase3/firebase.dart';
import 'package:fnx_ui/fnx_ui.dart';
import 'package:rpg_manager/component/rpg_attribute.dart';
import 'package:rpg_manager/component/rpg_hero.dart';
import 'package:rpg_manager/component/rpg_quest.dart';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/pipes.dart';

@Component(selector: 'screen-login', templateUrl: 'screen_login.html',
    directives: const [RpgHero, RpgAttribute, RpgQuest],
    pipes: const [AsDatePipe, AsDateLongPipe]
)
class ScreenLogin {

  FnxApp app;
  Game game;
  Database database;

  ScreenLogin(this.app, this.game, this.database);

  void loginWithGoogle() {
    database.app.auth().signInWithPopup(new GoogleAuthProvider()).then((UserCredential u) {
      if (u.user == null) {
        app.toast("Please, log in, otherwise we will not move at all");
        return;
      } else {
        app.toast("You are logged in as ${u.user.displayName}");
        game.initWithUser(u.user);
      }
    });
  }

}
