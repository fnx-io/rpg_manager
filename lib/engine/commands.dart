library commands;

import 'dart:async';
import 'package:rpg_manager/engine/engine.dart';
import 'package:rpg_manager/engine/names.dart';
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:rpg_manager/model/skills.dart';
import 'package:rpg_manager/model/dice.dart' as g;

part 'commands_heroes.dart';
part 'commands_quests.dart';

///
/// This is an atomic operation applicable to the game state.
///
abstract class Command<T> {

  T execute(Engine e);

}