// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

class Piece {
  final int _key;

  int get key => _key;

  Piece(this._key);
}


class EdgePiece extends Piece {
  Edge get edge => Edge.fromKey(key);

  EdgePiece(int key) : super(key) {
    if (Edge.validKey(key)) {
      print("WARNING!!! ${this.runtimeType} can only exist between two ${CoordinateType.Plot} coordinates");
    }
  }

  String toString() => "${this.runtimeType} ${edge}";
}


class NodePiece extends Piece {
  Coordinate get coordinate => Coordinate.fromKey(key);

  NodePiece(int key, CoordinateType legalType) : super(key) {
    if (Coordinate.validKey(key) && coordinate.type != legalType) {
      print("WARNING!!! ${this.runtimeType} can not be placed on a ${coordinate.type}");
    }
  }

  String toString() => "${this.runtimeType} ${coordinate}";
}


class TilePiece extends NodePiece {
  TilePiece(int key) : super(key, CoordinateType.Tile);
}


class PlotPiece extends NodePiece {
  PlotPiece(int key) : super(key, CoordinateType.Plot);
}


class Building extends PlotPiece {
  int production = 1;

	Building(this.production, int key) : super(key);

  Set<int> blockedPlots() {
    Set<int> plots = new Set<int>();
    List<Coordinate> neighborPlots = coordinate.neighbors().where((coord) => coord.type == CoordinateType.Plot);
    plots.addAll(neighborPlots.map((coord) => coord.key));
    plots.add(key);
    return plots;
  }

  String toString() => "${super.toString()}:${production}";
}

class Tile extends TilePiece {
  int _typeIndex = 0;
  TileType get type => TileType.values[_typeIndex];
  int token = 0;

  ResourceType get resource => yields(type);

  Tile(int key) : super(key);

  void changeType([TileType type]) {
    if (type != null) _typeIndex = TileType.values.indexOf(type);
    else _typeIndex = (_typeIndex + 1) % TileType.values.length;
  }

  void changeToken(newToken) {
    if (newToken < 2 || newToken > 12) print('WARNING!!! invalid token number ${newToken}');
    token = newToken;
  }

  // Tile coordinates are initially surrounded by only plot coordinates, we can
  // use the neighbors of those initial neighbor plots to find the surrounding
  // Tile coordinates.
  Set<int> expansionTiles() {
    Set<int> tiles = new Set<int>();
    coordinate.neighbors().forEach((plotCoord) {
      List<Coordinate> extendedCoords = new List<Coordinate>.from(plotCoord.neighbors().where((coord) => coord.type == CoordinateType.Tile));
      tiles.addAll(extendedCoords.map((coord) => coord.key));
    });
    tiles.remove(key);
    return tiles;
  }
}
