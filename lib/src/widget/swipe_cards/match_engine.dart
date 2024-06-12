import 'package:flutter/widgets.dart';

class MatchEngine extends ChangeNotifier {
  final int _itemCount;
  late int _currentItemIndex;

  MatchEngine({
    required int itemCount,
  }) : _itemCount = itemCount {
    _currentItemIndex = _itemCount > 0 ? 0 : -1;
  }

  int get length => _itemCount;

  bool get isLast => _currentItemIndex + 1 == _itemCount;

  bool get isFinish => _currentItemIndex >= _itemCount;

  int? get previousIndex => _currentItemIndex - 1 > 0 ? _currentItemIndex - 1 : null;

  int get index => _currentItemIndex;

  int? get nextIndex => _currentItemIndex + 1 < _itemCount ? _currentItemIndex + 1 : null;

  void match() {
    _currentItemIndex += 1;
    notifyListeners();
  }

  void rewindMatch() {
    if (_currentItemIndex != 0) {
      _currentItemIndex -= 1;
      notifyListeners();
    }
  }

  void resetMatch() {
    _currentItemIndex = _itemCount > 0 ? 0 : -1;
    notifyListeners();
  }
}
