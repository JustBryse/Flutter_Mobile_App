class ThreadTag {
  int _id = -1;
  String _name = "";
  int _threadId = -1;

  String get name => _name;

  @override
  String toString() {
    return _name;
  }

  ThreadTag.none() {
    _id = -1;
    _name = "";
    _threadId = -1;
  }

  ThreadTag.name(String name) {
    _id = -1;
    _name = name;
    _threadId = -1;
  }

  ThreadTag.all(int id, String name, int threadId) {
    _id = id;
    _name = name;
    _threadId = threadId;
  }
}
