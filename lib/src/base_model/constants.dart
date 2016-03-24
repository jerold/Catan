// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

List<int> defaultCoordinateKeys = [
  4139, 4038, 4141, 4042, 3839,
  3841, 4338, 4137, 4340, 4040,
  4036, 3837, 4342, 4143, 4044,
  3843, 3738, 3740, 3742
];

List<int> standardDealKeys = [
  3742, 3740, 3738, 3837, 4036, 4137, 4338, 4340, 4342, 4143,
  4044, 3843, 3841, 3839, 4038, 4139, 4141, 4042, 4040
];

List<TerrainType> defaultTiles = [
  TerrainType.Desert,
  TerrainType.Pasture, TerrainType.Pasture, TerrainType.Pasture, TerrainType.Pasture,
  TerrainType.Field, TerrainType.Field, TerrainType.Field, TerrainType.Field,
  TerrainType.Forest, TerrainType.Forest, TerrainType.Forest, TerrainType.Forest,
  TerrainType.Hill, TerrainType.Hill, TerrainType.Hill,
  TerrainType.Mountain, TerrainType.Mountain, TerrainType.Mountain,
];

List<int> defaultTokens = [
  2,
  3, 3,
  4, 4,
  5, 5,
  6, 6,
  8, 8,
  9, 9,
  10, 10,
  11, 11,
  12,
];

List<int> standardOrderTokens = [
  5, 2, 6, 3, 8, 10, 9, 12, 11, 4, 8,
  10, 9, 4, 5, 6, 3, 11,
];

List<int> chanceList = [1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1];

int chances(int roll) => roll >= 2 && roll <= 12 ? chanceList[roll - 2] : 0;

num probability(int roll) => chances(roll) / 36;

enum Direction {
  NorthEast, East, SouthEast, SouthWest, West, NorthWest,
}

enum CoordinateType {
  Plot,
  Tile,
}

String coordinateTypeString(CoordinateType type) => type == CoordinateType.Plot ? 'Plot' : 'Tile';

const String TerrainStringDesert = 'D';
const String TerrainStringPasture = 'P';
const String TerrainStringField = 'F';
const String TerrainStringForest = 'L';
const String TerrainStringHill = 'H';
const String TerrainStringMountain = 'M';

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
      return TerrainStringPasture;
    case TerrainType.Field:
      return TerrainStringField;
    case TerrainType.Forest:
      return TerrainStringForest;
    case TerrainType.Hill:
      return TerrainStringHill;
    case TerrainType.Mountain:
      return TerrainStringMountain;
    default:
      return TerrainStringDesert;
  }
}

String stringFromResourceType(ResourceType type) {
  switch(type) {
    case ResourceType.Brick:
      return 'Brick';
    case ResourceType.Lumber:
      return 'Lumber';
    case ResourceType.Ore:
      return 'Ore';
    case ResourceType.Sheep:
      return 'Sheep';
    case ResourceType.Wheat:
      return 'Wheat';
    default:
      return 'Unknown';
  }
}

TerrainType terrainTypeFromString(String typeString) {
  switch(typeString) {
    case TerrainStringPasture:
      return TerrainType.Pasture;
    case TerrainStringField:
      return TerrainType.Field;
    case TerrainStringForest:
      return TerrainType.Forest;
    case TerrainStringHill:
      return TerrainType.Hill;
    case TerrainStringMountain:
      return TerrainType.Mountain;
    default:
      return TerrainType.Desert;
  }
}

const String PlayerColorWhite = 'rgb(220, 220, 220)';
const String PlayerColorBlack = 'rgb(50, 50, 50)';
const String PlayerColorRed = 'rgb(192, 46, 29)';
const String PlayerColorOrange = 'rgb(241, 108, 32)';
const String PlayerColorYellow = 'rgb(235, 200, 68)';
const String PlayerColorGreen = 'rgb(162, 184, 108)';
const String PlayerColorBlue = 'rgb(19, 149, 186)';
const String PlayerColorPurple = 'rgb(13, 60, 85)';
const String PlayerColorBrown = 'rgb(217, 78, 32)';

List<String> PlayerColors = [
  PlayerColorWhite, PlayerColorBlack, PlayerColorRed,
  PlayerColorOrange, PlayerColorYellow, PlayerColorGreen,
  PlayerColorBlue, PlayerColorPurple, PlayerColorBrown,
];
