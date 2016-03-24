// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

class Coordinate {
  int _x;
  int get x => _x;
  int _y;
  int get y => _y;

  CoordinateType get type {
    switch((x  - (y % 2)) % 3) {
      case 1:
        return CoordinateType.Tile;
      default:
        return CoordinateType.Plot;
    }
  }

  Coordinate(this._x, this._y);

  Coordinate.initial() {
    this._x = 40;
    this._y = 40;
  }

  Coordinate.fromKey(int key) {
    this._x = key ~/ 100;
    this._y = key % 100;
  }

  Coordinate neighbor(Direction dir) {
    switch(dir) {
      case Direction.NorthEast:
        return new Coordinate(x + (y % 2), y - 1);
      case Direction.East:
        return new Coordinate(x + 1, y);
      case Direction.SouthEast:
        return new Coordinate(x + (y % 2), y + 1);
      case Direction.SouthWest:
        return new Coordinate(x - ((y + 1) % 2), y - 1);
      case Direction.West:
        return new Coordinate(x - 1, y);
      case Direction.NorthWest:
        return new Coordinate(x - ((y + 1) % 2), y + 1);
      default:
        return null;
    }
  }

  List<Coordinate> neighbors() => new List<Coordinate>()
    ..addAll(Direction.values.map((pos) => neighbor(pos)));

  int toKey() => x * 100 + y;
  String toString() => "${coordinateTypeString(type)}{${x},${y}}";
}
