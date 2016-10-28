import 'dart:async';

import 'package:firebase3/firebase.dart';
import 'package:logging/logging.dart';
import 'package:rpg_manager/engine/commands.dart' as command;
import 'package:rpg_manager/engine/commands.dart';
import 'package:rpg_manager/model/dice.dart' as g;
import 'package:rpg_manager/model/game.dart';
import 'package:rpg_manager/model/heroes.dart';
import 'package:rpg_manager/model/quests.dart';
import 'package:fnx_profiler/fnx_profiler.dart';

const int TIME_SCALE = 24 * 120;//(24 * 60 * 60 / 60; // 30 sec is one day
const int TICK_MS = 4321; // tick every X ms
const Duration SCALED_TICK_DURATION = const Duration(milliseconds: TICK_MS * TIME_SCALE );

const double DEFAULT_QUEST_IN_TICK_PROBABILITY = 0.02;
const double DEFAULT_HERO_IN_TICK_PROBABILITY = 0.01;

const String STATE_NO_USER = "noUser";
const String STATE_LOADING = "loading";
const String STATE_READY = "ready";



/// This is the game engine, contains reference to the [Game] state
/// and can execute [CommandType]s on it. Also holds Firebase reference.
class Engine {

  Logger log = new Logger("Engine");
  Profiler profiler = openRootProfiler("rpg");

  App firebase;
  DatabaseReference database;

  Game game = new Game();
  DateTime lastSave;
  double questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
  double heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;

  Stream<EngineEvent> events;
  StreamController<EngineEvent> _controller = new StreamController();

  StreamSubscription<AuthEvent> firebaseAuthEvents;

  Timer tickGenerator;

  String _engineState;

  String get engineState => _engineState;

  set engineState(String value) {
    _engineState = value;
    log.info("Engine state: ${engineState}");
  }

  Engine(this.firebase) {
    _controller = new StreamController();
    events = _controller.stream;
    engineState = STATE_NO_USER;

    log.info("Waiting for Firebase user");
    firebaseAuthEvents = firebase.auth().onAuthStateChanged.listen((AuthEvent auth) {
      if (auth.user != null) {
        log.info("Received Firebase user ${auth.user}");
        if (game.loggedUser == null || game.loggedUser.uid != auth.user.uid) {
          log.info("Initializing game");
          engineState = STATE_LOADING;
          profiler.profileFuture("init", initWithUser(auth.user));
        }
      } else {
        // drop all, we lost the user
        log.info("User logged out");
        game = new Game();
        tickGenerator.cancel();
      }
    });

  }

  Object executeCommand(command.Command<Object> cmd) {
    Profiler child = profiler.openChild(cmd.runtimeType.toString());
    log.fine("Executing command: ${cmd}");
    Object result = cmd.execute(this);
    log.fine("... done (${cmd}");
    child.close();
    return result;
  }

  Future initWithUser(User user) async {
    engineState = STATE_LOADING;
    game = new Game();
    game.loggedUser = user;

    if (tickGenerator != null) tickGenerator.cancel();

    database = firebase.database().ref(user.uid).child("game");

    log.info("Waiting for Firebase data");
    Map data = (await database.once("value")).snapshot.val();

    if (data == null) {
      log.info("Generating new game");
      game.currentTime = new DateTime(267, 1, 1, 12, 0);

      for (int a = 0; a < 10; a++) {
        executeCommand(new GenerateHero());
      }

      for (int a = 0; a < 5; a++) {
        executeCommand(new GenerateNewQuest(g.Difficulty.AVG));
      }
      await save();
    } else {
      log.info("Loading game from Firebase");
      game.fromMap(data);
    }

    tickGenerator = new Timer.periodic(new Duration(milliseconds: TICK_MS), doTick);
    engineState = STATE_READY;
    return true;
  }

  Future save() async {
    await profiler.profileFuture("save",
        database.set(game.toMap()).then((_) => log.info("Game saved"))
    );
    lastSave = new DateTime.now();
    return;
  }

  void doTick(Timer timer) {
    assert(game.loggedUser != null);

    int day = game.currentTime.day;
    game.currentTime = game.currentTime.add(SCALED_TICK_DURATION);

    if (day != game.currentTime.day) {
      _controller.sink.add(new EngineEvent(EngineEventType.NEW_DAY));

      game.hiredHeroes.forEach((Hero h) {
        int money = h.dailySalary;
        if (game.money < money) {
          new Future.microtask(() {
            game.heroesCatalogue.remove(h);
            _controller.sink.add(new EngineEvent(EngineEventType.HERO_LEFT, h));
          });
        } else {
          game.money -= money;
        }
      });
      printProfilerStats();
    }

    if (game.availableQuests.length < 20) {
      if (g.rnd.nextDouble() < questProbability) {
        Quest q = executeCommand(new command.GenerateNewQuest());
        _controller.sink.add(new EngineEvent(EngineEventType.NEW_QUEST, q));
        questProbability = DEFAULT_QUEST_IN_TICK_PROBABILITY;
      } else {
        questProbability = questProbability * 1.2;
      }
    }
    if (game.heroesToHire.length < 20) {
      if (g.rnd.nextDouble() < heroProbability) {
        Hero h = executeCommand(new command.GenerateHero());
        _controller.sink.add(new EngineEvent(EngineEventType.NEW_HERO, h));
        heroProbability = DEFAULT_HERO_IN_TICK_PROBABILITY;
      } else {
        heroProbability = heroProbability * 1.2;
      }
    }

    game.questsInProgress.where((Quest q) => q.progress(game.currentTime) >= 1).forEach((Quest q) {
      log.info("Quest finished: $q");

      // resolving quest involves removing quest from catalogue, which leads to concurrent modification
      // of 'questsInProgress'
      new Future.microtask(() {
        QuestResult questResult = executeCommand(new command.EvaluateQuestResult(q));
        _controller.sink.add(new EngineEvent(EngineEventType.QUEST_FINISHED, questResult));
        save();
      });
    });

    _controller.sink.add(new EngineEvent(EngineEventType.TICK));
  }

}

enum EngineEventType {
  TICK, NEW_DAY, NEW_QUEST, NEW_HERO, QUEST_FINISHED, HERO_LEFT
}

class EngineEvent {

  EngineEventType type;
  Object param;

  EngineEvent(this.type, [this.param]);

}
