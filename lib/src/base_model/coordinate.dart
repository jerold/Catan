// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

final int INITIAL_KEY = 4040;
final int INITIAL_H = 40;
final int INITIAL_V = 40;
final num SPACING_X = 1.0;
final num SPACING_Y = sin(PI * (1 / 3));


Map<int, Coordinate> _coordCache = new Map<int, Coordinate>();

class Coordinate {
  static Coordinate fromKey(int key) => _coordCache.putIfAbsent(key, () => new Coordinate(key ~/ 100, key % 100));

  static Coordinate initial() => Coordinate.fromKey(INITIAL_KEY);

  static bool validKey(int key) => key > 0 && key < 10000;

  static int getKey(int h, int v) => h * 100 + v;

  static Point getPoint(int h, int v) => new Point(
    (h * SPACING_X) + (SPACING_X / 2 * (v % 2)) - (INITIAL_H * SPACING_X),
    (v * SPACING_Y) - (INITIAL_V * SPACING_Y)
  );

  static CoordinateType getType(int h, int v) => (h  - (v % 2)) % 3 == 1 ? CoordinateType.Tile : CoordinateType.Plot;

  /// Horizontal key component
  final int _h;

  /// Vertical key component
  final int _v;

  final int _key;
  final Point _point;
  final CoordinateType _type;

  int get key => _key;
  Point get point => _point;
  CoordinateType get type => _type;

  Coordinate(int h, int v) :
    _h = h,
    _v = v,
    _key = Coordinate.getKey(h, v),
    _point = Coordinate.getPoint(h, v),
    _type = Coordinate.getType(h, v);

  Coordinate neighbor(Direction dir) {
    switch(dir) {
      case Direction.NorthEast: return Coordinate.fromKey(Coordinate.getKey(_h + (_v % 2), _v - 1));
      case Direction.East:      return Coordinate.fromKey(Coordinate.getKey(_h + 1, _v));
      case Direction.SouthEast: return Coordinate.fromKey(Coordinate.getKey(_h + (_v % 2), _v + 1));
      case Direction.SouthWest: return Coordinate.fromKey(Coordinate.getKey(_h - ((_v + 1) % 2), _v - 1));
      case Direction.West:      return Coordinate.fromKey(Coordinate.getKey(_h - 1, _v));
      case Direction.NorthWest: return Coordinate.fromKey(Coordinate.getKey(_h - ((_v + 1) % 2), _v + 1));
    }
  }

  List<Coordinate> neighbors({CoordinateType ofType}) {
    var coords = Direction.values.map((pos) => neighbor(pos));
    if (ofType == null) return new List<Coordinate>.from(coords);
    else return new List<Coordinate>.from(coords.where((coord) => coord.type == ofType));
  }

  String toString() => "${coordinateTypeString(type)}${key}{${point}}";
}
