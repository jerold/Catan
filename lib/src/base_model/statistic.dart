// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

class Statistic {
  List<num> _values = new List<num>();
  bool _perfectCache = false;

  num _cachedAvg;
  num _cachedMax;
  num _cachedMin;

  add(num newVal) {
    _values.add(newVal);
    _perfectCache = false;
  }

  void clear() {
    _values.clear();
    _perfectCache = false;
  }

  bool _updateCache() {
    if (_values.length > 0) {
      _cachedAvg = _values.fold(0.0, (sum, next) => sum + next) / _values.length;
      _cachedMax = _values.reduce(max);
      _cachedMin = _values.reduce(min);
    } else {
      _cachedAvg = 0.0;
      _cachedMax = 0.0;
      _cachedMin = 0.0;
    }

    return _perfectCache = true;
  }

  num getAvg() {
    if (!_perfectCache) _updateCache();
    return _cachedAvg;
  }

  num getMax() {
    if (!_perfectCache) _updateCache();
    return _cachedMax;
  }

  num getMin() {
    if (!_perfectCache) _updateCache();
    return _cachedMin;
  }
}
