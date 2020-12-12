import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:security_control/models/history.dart';
import 'package:security_control/services/history_service.dart';
import 'package:security_control/services/service_locator.dart';

DateFormat timeFormat = DateFormat('yyyy/MM/dd  HH:mm');

class BatterystationViewModel extends BaseViewModel {
  var _historyService = locator<HistorySyncService>();
  String _title = "Batterystation";
  List _items = [];

  String get title => _title;
  List get items => _items;

  BatterystationViewModel() {
    print('BatterystationViewModel Constructor');
    if (!(_items.length > 0)) {
      _showLoadingIndicator();
    }
  }
  initialise() {
    print('BatterystationViewModel initialise');
    _historyService.getHistory(DateTime.now());
    print('_items.length: ${_items.length}');
  }

  listener() async {
    //Start update listener
    print('BatterystationViewModel Start update listener');
    _historyService.historyListStream.listen((event) {
      _items.addAll(event);
      _removeLoadingIndicator();
      notifyListeners();
    });
  }

  void _showLoadingIndicator() {
    print('loading indicator added');
    _items.add(History.loading());
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _items.removeWhere((element) => element.id == -5);
    notifyListeners();
  }
}

class StatusSectionViewModel extends BatterystationViewModel {
  String _name;
  bool _status = false;
  String _statusSectionTitle = "Current status:";

  String get name => _name;
  bool get status => _status;
  String get statusSectionTitle => _statusSectionTitle;

  @override
  listener() async {
    //Start update listener
    print('StatusSectionViewModel Start update listener');
    _historyService.statusListStream.listen((event) {
      event[0] == 1 ? _status = true : _status = false;
      _name = event[1];
      print("status updated: $_status $_name");
      notifyListeners();
    });
  }

  StatusSectionViewModel() {
    _historyService.getStatus();
  }
}

class LatestSectionViewModel extends BatterystationViewModel {
  String _latestSectionTitle = "Latest Battery Change";
  String get latestSectionTitle => _latestSectionTitle;
  History get recentDevice => _items.first;
}

class HistorySectionViewModel extends BatterystationViewModel {
  int itemRequestThreshold = 10;
  DateTime _shownHistory = DateTime.now();

  String _historySectionTitle = "History";
  String get historySectionTitle => _historySectionTitle;

  Future handleHistoryItemCreated(int index) async {
    // if (_items.length < itemRequestThreshold)
    //   itemRequestThreshold = _items.length;
    var itemPosition = index + 1;
    var requestMoreData =
        itemPosition % itemRequestThreshold == 0 && itemPosition != 0;
    var pageToRequest = _items.last.timestamp ?? DateTime.now();
    if ((requestMoreData && _shownHistory.isAfter(pageToRequest))) {
      // print('pageToRequest: ${timeFormat.format(pageToRequest)}');
      _shownHistory = pageToRequest;
      await _historyService.getHistory(pageToRequest);
    }
  }
}
