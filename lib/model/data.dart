abstract class Catalogue<T extends Entity> {

  static int _id = new DateTime.now().millisecondsSinceEpoch;

  int _generateId() =>_id++;

  Map<int, T> _repo = {};

  T findById(int id) {
    if (id == null) return null;
    return _repo[id];
  }

  Iterable<T> get all => _repo.values;

  void remove(T t) {
    _repo.remove(t.id);
  }

  void registerExisting(T t) {
    if (t.id == null) throw "Null id";
    _repo[t.id] = t;
  }

  void registerNew(T t) {
    if (t.id != null) throw "Id not null!";
    t.id = _generateId();
    _repo[t.id] = t;
  }

}

class Entity {

  int id;

}