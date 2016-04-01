// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

final int INITIAL_H = 40;
final int INITIAL_V = 40;
final num SPACING_X = 1.0;
final num SPACING_Y = sin(PI * (1 / 3));

class Coordinate {
  /// Horizontal key component
  final int _h;

  /// Vertical key component
  final int _v;

  Point _cachedPoint;
  CoordinateType _cachedType;

  Point get point => _cachedPoint;
  CoordinateType get type => _cachedType;

  Coordinate(this._h, this._v) {
    _cachedType = (_h  - (_v % 2)) % 3 == 1 ? CoordinateType.Tile : CoordinateType.Plot;
    _cachedPoint = new Point(
      (_h * SPACING_X) + (SPACING_X / 2 * (_v % 2)) - (INITIAL_H * SPACING_X),
      (_v * SPACING_Y) - (INITIAL_V * SPACING_Y)
    );
  }

  factory Coordinate.initial() => new Coordinate(INITIAL_H, INITIAL_V);

  factory Coordinate.fromKey(int key) => new Coordinate(key ~/ 100, key % 100);

  Coordinate neighbor(Direction dir) {
    switch(dir) {
      case Direction.NorthEast: return new Coordinate(_h + (_v % 2), _v - 1);
      case Direction.East:      return new Coordinate(_h + 1, _v);
      case Direction.SouthEast: return new Coordinate(_h + (_v % 2), _v + 1);
      case Direction.SouthWest: return new Coordinate(_h - ((_v + 1) % 2), _v - 1);
      case Direction.West:      return new Coordinate(_h - 1, _v);
      case Direction.NorthWest: return new Coordinate(_h - ((_v + 1) % 2), _v + 1);
    }
  }

  List<Coordinate> neighbors({CoordinateType ofType}) {
    var coords = Direction.values.map((pos) => neighbor(pos));
    if (ofType == null) return new List<Coordinate>.from(coords);
    else return new List<Coordinate>.from(coords.where((coord) => coord.type == ofType));
  }

  int toKey() => _h * 100 + _v;
  String toString() => "${coordinateTypeString(type)}${toKey()}{point}";
}
