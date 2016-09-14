abstract class Catalogue<T extends Entity> {

  static int _id = new DateTime.now().millisecondsSinceEpoch;

  int _generateId() =>_id++;

  Map<int, T> _repo = {};

  T createNew() {
    T result = createNewImpl();
    result.id = _generateId();
    register(result);
    return result;
  }

  T findById(int id) {
    if (id == null) return null;
    return _repo[id];
  }

  T createNewImpl();

  Iterable<T> get all => _repo.values;

  void remove(T t) {
    _repo.remove(t.id);
  }

  void register(T t) {
    if (t.id == null) throw "Null id";
    _repo[t.id] = t;
  }


}

class Entity {

  int id;

}