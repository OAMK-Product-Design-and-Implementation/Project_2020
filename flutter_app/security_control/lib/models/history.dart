class History {
  int _id = 0;
  String _name;
  DateTime _timestamp;

  History(this._name, this._timestamp);

  History.empty();
  History.loading() {
    _id = -5;
  }

  History.fromJson(String name, String timestamp) {
    this._name = name;
    this._timestamp = DateTime.parse(timestamp);
  }

  int get id => _id;
  String get name => _name;
  DateTime get timestamp => _timestamp;

  void setId(int i) => _id = i;
}
