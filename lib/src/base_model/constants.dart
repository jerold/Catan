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

List<Terrain> defaultTiles = [
  Terrain.Desert,
  Terrain.Pasture, Terrain.Pasture, Terrain.Pasture, Terrain.Pasture,
  Terrain.Field, Terrain.Field, Terrain.Field, Terrain.Field,
  Terrain.Forest, Terrain.Forest, Terrain.Forest, Terrain.Forest,
  Terrain.Hill, Terrain.Hill, Terrain.Hill,
  Terrain.Mountain, Terrain.Mountain, Terrain.Mountain,
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
  5, 2, 6, 3, 8, 10, 9, 12, 11,
  4, 8, 10, 9, 4, 5, 6, 3, 11,
];

List<int> chanceList = [1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1];

int chances(int roll) => roll >= 2 && roll <= 12 ? chanceList[roll - 2] : 0;

num probability(int roll) => chances(roll) / 36;

String coordinateTypeString(CoordinateType type) => type == CoordinateType.Plot ? 'Plot' : 'Tile';

const String TileStringDesert = 'D';
const String TileStringPasture = 'P';
const String TileStringField = 'F';
const String TileStringForest = 'L';
const String TileStringHill = 'H';
const String TileStringMountain = 'M';



String stringFromTerrain(Terrain type) {
  switch(type) {
    case Terrain.Pasture:
      return TileStringPasture;
    case Terrain.Field:
      return TileStringField;
    case Terrain.Forest:
      return TileStringForest;
    case Terrain.Hill:
      return TileStringHill;
    case Terrain.Mountain:
      return TileStringMountain;
    default:
      return TileStringDesert;
  }
}

String stringFromResource(Resource type) {
  switch(type) {
    case Resource.Brick:
      return 'Brick';
    case Resource.Lumber:
      return 'Lumber';
    case Resource.Ore:
      return 'Ore';
    case Resource.Sheep:
      return 'Sheep';
    case Resource.Wheat:
      return 'Wheat';
    default:
      return 'Unknown';
  }
}

Terrain tileTypeFromString(String typeString) {
  switch(typeString) {
    case TileStringPasture:
      return Terrain.Pasture;
    case TileStringField:
      return Terrain.Field;
    case TileStringForest:
      return Terrain.Forest;
    case TileStringHill:
      return Terrain.Hill;
    case TileStringMountain:
      return Terrain.Mountain;
    default:
      return Terrain.Desert;
  }
}

const String PlayerColorRed = 'red';
const String PlayerColorBlue = 'blue';
const String PlayerColorGrey = 'grey';
const String PlayerColorOrange = 'orange';
const String PlayerColorGreen = 'green';
const String PlayerColorBrown = 'brown';

List<String> PlayerColors = [
  PlayerColorRed, PlayerColorBlue, PlayerColorGrey,
  PlayerColorOrange, PlayerColorGreen, PlayerColorBrown,
];
