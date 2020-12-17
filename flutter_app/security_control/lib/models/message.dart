import 'dart:convert';

class Message {
  int _id;
  String _deviceName;
  String _messageType;
  String _timestamp;
  String _explanation;

  Function(int)
      _clearMsgCallBack; // If not null, called when setName() is called

  Message(this._id, this._deviceName, this._messageType, this._timestamp,
      this._explanation,
      [Function(int) clearMsgCallBack]) {
    if (clearMsgCallBack != null) {
      _clearMsgCallBack = clearMsgCallBack;
    }
  }

  Message.fromJson(String content, [Function(int) clearMsgCallBack]) {
    // Server brings our info in list form unfortunately, so we must do this manually
    // Content =
    List details = jsonDecode(content)[0];
    this._id = details[0];
    this._messageType = details[1];
    this._timestamp = details[2];
    this._deviceName = details[3];
    if (clearMsgCallBack != null) {
      _clearMsgCallBack = clearMsgCallBack;
    }
  }

  String get deviceName => _deviceName;
  int get id => _id;
  String get timestamp => _timestamp;
  String get explanation => _explanation;
  String get messageType => _messageType;

  void clear() {
    if (_clearMsgCallBack != null) {
      _clearMsgCallBack(_id);
    }
  }
}
