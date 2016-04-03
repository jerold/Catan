// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


int _edgeAKey(int key) => key ~/ 10000;
int _edgeBKey(int key) => key % 10000;


Map<int, Edge> _edgeCache = new Map<int, Edge>();

class Edge {
  static void clear() => _edgeCache.clear();

  static Edge fromKey(int key) => _edgeCache.putIfAbsent(key, () => new Edge(_edgeAKey(key), _edgeBKey(key)));

  static bool validKey(int key) {
    int aKey = _edgeAKey(key);
    int bKey = _edgeBKey(key);
    CoordinateType aType = Coordinate.getType(aKey);
    CoordinateType bType = Coordinate.getType(bKey);
    return Coordinate.fromKey(aKey).neighbors().values.contains(bKey)
      && aType == CoordinateType.Plot
      && bType == CoordinateType.Plot;
  }

  static int getKey(int aKey, int bKey) => max(aKey, bKey) * 10000 + min(aKey, bKey);

  /// Start key component
  final int _aKey;

  /// End key component
  final int _bKey;

  final int _key;

  int get key => _key;

  double get length => Coordinate.getPoint(_aKey).distanceTo(Coordinate.getPoint(_bKey));

  Edge(int aKey, int bKey) :
      _aKey = max(aKey, bKey),
      _bKey = min(aKey, bKey),
      _key = Edge.getKey(aKey, bKey);

  List<Coordinate> ends() => new List<Coordinate>()
    ..add(Coordinate.fromKey(_aKey))
    ..add(Coordinate.fromKey(_bKey));

  String toString() => "E${key}{${Coordinate.fromKey(_aKey).point} <-> ${Coordinate.fromKey(_bKey).point}}";
}
