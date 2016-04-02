// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


Map<int, Edge> _edgeCache = new Map<int, Edge>();

class Edge {
  static Edge fromKey(int key) => _edgeCache.putIfAbsent(key, () => new Edge(key ~/ 10000, key % 10000));

  static bool validKey(int key) {
    int aKey = key ~/ 10000;
    int bKey = key % 10000;
    CoordinateType aType = Coordinate.getType(aKey ~/ 100, aKey % 100);
    CoordinateType bType = Coordinate.getType(bKey ~/ 100, bKey % 100);
    return aType == CoordinateType.Plot && bType == CoordinateType.Plot;
  }

  static int getKey(int aKey, int bKey) => max(aKey, bKey) * 10000 + min(aKey, bKey);

  /// Start key component
  final int _aKey;

  /// End key component
  final int _bKey;

  final int _key;

  int get key => _key;

  Edge(int aKey, int bKey) :
    _aKey = max(aKey, bKey),
    _bKey = min(aKey, bKey),
    _key = Edge.getKey(aKey, bKey);

  List<Coordinate> ends() => new List<Coordinate>()
    ..add(Coordinate.fromKey(_aKey))
    ..add(Coordinate.fromKey(_bKey));

  String toString() => "E${key}{${Coordinate.fromKey(_aKey).point} to ${Coordinate.fromKey(_aKey).point}}";
}
