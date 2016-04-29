// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


enum CoordinateType {
  Plot, Tile,
}

enum Direction {
  NorthEast, East, SouthEast, SouthWest, West, NorthWest,
}

List<Direction> get DIRECTIONS => Direction.values;

final int INITIAL_KEY = 4040;
final int INITIAL_H = 40;
final int INITIAL_V = 40;
final num SPACING_X = 1.0;
final num SPACING_Y = sin(PI * (1 / 3));

Direction opposite(Direction fromDir) => DIRECTIONS[DIRECTIONS.indexOf(fromDir) + 3 % DIRECTIONS.length];
Direction clockwise(Direction fromDir) => DIRECTIONS[DIRECTIONS.indexOf(fromDir) + 1 % DIRECTIONS.length];
Direction counterClockwise(Direction fromDir) => DIRECTIONS[DIRECTIONS.indexOf(fromDir) - 1 % DIRECTIONS.length];

int _coordHKey(int key) => key ~/ 100;
int _coordVKey(int key) => key % 100;


Map<int, Coordinate> _coordCache = new Map<int, Coordinate>();

class Coordinate {
  static void clear() => _coordCache.clear();

  static Coordinate fromKey(int key) => _coordCache.putIfAbsent(key, () => new Coordinate(_coordHKey(key), _coordVKey(key)));

  static Coordinate initial() => Coordinate.fromKey(INITIAL_KEY);

  static bool validKey(int key) => key > 0 && key < 10000;

  static int _getKey(int h, int v) => h * 100 + v;

  static Map<Direction, int> getNeighbors(int key) => _getNeighbors(_coordHKey(key), _coordVKey(key));
  static Map<Direction, int> _getNeighbors(int h, int v) {
    Map<Direction, int> neighborMap = new Map<Direction, int>();
    neighborMap[Direction.NorthEast] = Coordinate._getKey(h + (v % 2), v - 1);
    neighborMap[Direction.East] = Coordinate._getKey(h + 1, v);
    neighborMap[Direction.SouthEast] = Coordinate._getKey(h + (v % 2), v + 1);
    neighborMap[Direction.SouthWest] = Coordinate._getKey(h - ((v + 1) % 2), v + 1);
    neighborMap[Direction.West] = Coordinate._getKey(h - 1, v);
    neighborMap[Direction.NorthWest] = Coordinate._getKey(h - ((v + 1) % 2), v - 1);
    return neighborMap;
  }

  static Point getPoint(int key) => validKey(key) ? _getPoint(_coordHKey(key), _coordVKey(key)) : null;
  static Point _getPoint(int h, int v) => new Point(
    (h * SPACING_X) + (SPACING_X / 2 * (v % 2)) - (INITIAL_H * SPACING_X),
    (v * SPACING_Y) - (INITIAL_V * SPACING_Y)
  );

  static CoordinateType getType(int key) => _getType(_coordHKey(key), _coordVKey(key));
  static CoordinateType _getType(int h, int v) => (h  - (v % 2)) % 3 == 1 ? CoordinateType.Tile : CoordinateType.Plot;

  /// Horizontal key component
  final int _h;

  /// Vertical key component
  final int _v;

  final int _key;
  final Map<Direction, int> _neighbors;
  final Point _point;
  final CoordinateType _type;

  int get key => _key;
  Point get point => _point;
  CoordinateType get type => _type;

  Coordinate(int h, int v) :
    _h = h,
    _v = v,
    _key = Coordinate._getKey(h, v),
    _neighbors = Coordinate._getNeighbors(h, v),
    _point = Coordinate._getPoint(h, v),
    _type = Coordinate._getType(h, v);

  int neighbor(Direction dir) => _neighbors[dir];

  Map<Direction, int> neighbors({CoordinateType ofType}) {
    if (ofType == null) return new Map<Direction, int>.from(_neighbors);

    Map<Direction, int> keyMap = new Map<Direction, int>();
    DIRECTIONS.forEach((dir) {
      int key = neighbor(dir);
      if (ofType == null || Coordinate.getType(key) == ofType) keyMap[dir] = key;
    });
    return keyMap;
  }

  String toString() => "${coordinateTypeString(type)}${key}{${point}}";
}
