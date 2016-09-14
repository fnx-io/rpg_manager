import 'dart:async';

import 'package:firebase3/firebase.dart';


abstract class FirebaseCollection<T extends FirebaseMap> {

  List<T> children = [];

  DatabaseReference ref;

  StreamSubscription<QueryEvent> subscription;

  FirebaseCollection(this.ref);

  Future<bool> load() {
    subscription = ref.onChildAdded.listen((QueryEvent eq) {
      if (eq.snapshot.val() != null) {
        print("Received data from list subscription ${eq.snapshot.val()}");
        Map<String, Object> persistentData = eq.snapshot.val() as Map<String, Object>;
        T obj = receivedData(eq.snapshot.ref, persistentData);
        obj.connect();
        children.add(obj);
      }
    });
    return ref.limitToFirst(1).onValue.first.then((QueryEvent event) => event.snapshot.val() != null) as Future<bool>;
  }

  T addNew() {
    return receivedData(ref.push().ref, null);
  }

  T receivedData(DatabaseReference ref, Map<String, Object> persistentData);

  void disconnect() {
    subscription.cancel();
    subscription = null;
  }
}

class FirebaseMap {

  DatabaseReference ref;
  Map<String, Object> persistentData;

  StreamSubscription<QueryEvent> subscription;

  FirebaseMap(this.ref, [this.persistentData = null]) {
    if (persistentData == null) persistentData = {};
  }

  /// Load's data from Firebase
  Future<Map<String, Object>> connect() {
    Completer<Map<String, Object>> completer = new Completer();
    if (subscription != null) throw "Already connected";

    subscription = ref.onValue.listen((QueryEvent eq) {
      print("Received data from map subscription ${eq.snapshot.val()}");
      persistentData = eq.snapshot.val() as Map<String, Object>;
      if (!completer.isCompleted) {
        if (persistentData == null) {
          persistentData = {};
          completer.complete(null);
        } else {
          completer.complete(persistentData);
        }
      }
    });
    return completer.future;
  }

  Future save() {
    return ref.set(persistentData);
  }

  void disconnect() {
    subscription.cancel();
    subscription = null;
  }

}

