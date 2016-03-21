// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

List<num> Probabilities = [0.03, 0.06, 0.08, 0.11, 0.14, 0.17, 0.14, 0.11, 0.08, 0.06, 0.03];

num probability(int val) => val >= 2 && val <= 12 ? Probabilities[val - 2] : 0.0;


const String TerrainTypeStringDesert = 'D';
const String TerrainTypeStringPasture = 'P';
const String TerrainTypeStringField = 'F';
const String TerrainTypeStringForest = 'L';
const String TerrainTypeStringHill = 'H';
const String TerrainTypeStringMountain = 'M';

enum TerrainType {
  Desert, Pasture, Field, Forest, Hill, Mountain,
}
enum ResourceType {
  None, Sheep, Wheat, Lumber, Brick, Ore,
}

ResourceType yields(TerrainType type) {
  switch(type) {
    case TerrainType.Pasture:
      return ResourceType.Sheep;
    case TerrainType.Field:
      return ResourceType.Wheat;
    case TerrainType.Forest:
      return ResourceType.Lumber;
    case TerrainType.Hill:
      return ResourceType.Brick;
    case TerrainType.Mountain:
      return ResourceType.Ore;
    default:
      return ResourceType.None;
  }
}

String stringFromTerrainType(TerrainType type) {
  switch(type) {
    case TerrainType.Pasture:
      return TerrainTypeStringPasture;
    case TerrainType.Field:
      return TerrainTypeStringField;
    case TerrainType.Forest:
      return TerrainTypeStringForest;
    case TerrainType.Hill:
      return TerrainTypeStringHill;
    case TerrainType.Mountain:
      return TerrainTypeStringMountain;
    default:
      return TerrainTypeStringDesert;
  }
}

TerrainType terrainTypeFromString(String typeString) {
  switch(typeString) {
    case TerrainTypeStringPasture:
      return TerrainType.Pasture;
    case TerrainTypeStringField:
      return TerrainType.Field;
    case TerrainTypeStringForest:
      return TerrainType.Forest;
    case TerrainTypeStringHill:
      return TerrainType.Hill;
    case TerrainTypeStringMountain:
      return TerrainType.Mountain;
    default:
      return TerrainType.Desert;
  }
}

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
  int harvestCount = 1;

	Building(this.harvestCount, Coordinate coordinate) : super(coordinate, CoordinateType.Plot);

  Set<int> blockedPlots() {
    Set<int> plots = new Set<int>();
    List<Coordinate> neighborPlots = coordinate.neighbors().where((coord) => coord.type == CoordinateType.Plot);
    plots.addAll(neighborPlots.map((coord) => coord.toKey()));
    plots.add(coordinate.toKey());
    return plots;
  }

  String toString() => "${super.toString()} H:${harvestCount}";
}

class Terrain extends Piece {
  int _typeIndex = 0;
  TerrainType get type => TerrainType.values[_typeIndex];
  int harvest = 0;

  ResourceType get resource => yields(type);

  Terrain(Coordinate coordinate) : super(coordinate, CoordinateType.Tile);

  void changeType([TerrainType type]) {
    if (type != null) _typeIndex = TerrainType.values.indexOf(type);
    else _typeIndex = (_typeIndex + 1) % TerrainType.values.length;
  }

  // Tile coordinates are initially surrounded by only plot coordinates, we can
  // use the neighbors of those initial neighbor plots to find the surrounding
  // Tile coordinates.
  Set<int> expansionTiles() {
    Set<int> tiles = new Set<int>();
    coordinate.neighbors().forEach((plotCoord) {
      List<Coordinate> extendedCoords = plotCoord.neighbors().where((coord) => coord.type == CoordinateType.Tile);
      tiles.addAll(extendedCoords.map((coord) => coord.toKey()));
    });
    tiles.remove(coordinate.toKey());
    return tiles;
  }
}
