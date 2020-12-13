import 'dart:convert';

class GoPiGo {
  int _id;
  String _name;
  int _batterylevel;
  String _location;
  bool _connected;
  Function(int, String)
      _updateNameCallBack; // If not null, called when setName() is called

  GoPiGo(this._id, this._name, this._batterylevel);
  GoPiGo.empty();

  GoPiGo.fromJson(String content, this._id,
      [Function(int, String) updateNameCallBack]) {
    // Server brings our info in list form unfortunately, so we must do this manually
    // Content =
    List details = jsonDecode(content)[0];
    this._name = details[0] ?? 'GoPiGo_$id';
    this._batterylevel = details[1]?.round() ?? 0;
    this._location = details[2] ?? 'lost';
    if (details[3] == 0) {
      this._connected = false;
    } else {
      this._connected = true;
    }
    if (updateNameCallBack != null) {
      _updateNameCallBack = updateNameCallBack;
    }
  }

  String get name => _name;
  int get id => _id;
  int get batterylevel => _batterylevel;
  bool get connected => _connected;
  String get location => _location;
  void setId(int i) => _id = i;
  void setBatteryLevel(int i) => _batterylevel = i;
  void setName(String newName) {
    _name = newName;
    if (_updateNameCallBack != null) {
      _updateNameCallBack(_id, _name);
    }
  }
}
