// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

class Piece {
  Coordinate coordinate;
  CoordinateType legal;

  Piece(this.coordinate, this.legal) {
    if (coordinate.type != legal) {
      print("WARNING!!! ${this.runtimeType} can not be placed on a ${coordinate.type}");
    }
  }

  String toString() => "${this.runtimeType} ${coordinate}";
}

class Thief extends Piece {
	Thief(Coordinate coordinate) : super(coordinate, CoordinateType.Tile);
}

class Building extends Piece {
  int production = 1;

	Building(this.production, Coordinate coordinate) : super(coordinate, CoordinateType.Plot);

  Set<int> blockedPlots() {
    Set<int> plots = new Set<int>();
    List<Coordinate> neighborPlots = coordinate.neighbors().where((coord) => coord.type == CoordinateType.Plot);
    plots.addAll(neighborPlots.map((coord) => coord.toKey()));
    plots.add(coordinate.toKey());
    return plots;
  }

  String toString() => "${super.toString()}:${production}";
}

class Terrain extends Piece {
  int _typeIndex = 0;
  TerrainType get type => TerrainType.values[_typeIndex];
  int token = 0;

  ResourceType get resource => yields(type);

  Terrain(Coordinate coordinate) : super(coordinate, CoordinateType.Tile);

  void changeType([TerrainType type]) {
    if (type != null) _typeIndex = TerrainType.values.indexOf(type);
    else _typeIndex = (_typeIndex + 1) % TerrainType.values.length;
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
      tiles.addAll(extendedCoords.map((coord) => coord.toKey()));
    });
    tiles.remove(coordinate.toKey());
    return tiles;
  }
}
