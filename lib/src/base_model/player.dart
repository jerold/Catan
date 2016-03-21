// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

const String ColorStringWhite = 'rgb(220, 220, 220)';
const String ColorStringBlack = 'rgb(50, 50, 50)';
const String ColorStringRed = 'rgb(192, 46, 29)';
const String ColorStringOrange = 'rgb(241, 108, 32)';
const String ColorStringYellow = 'rgb(235, 200, 68)';
const String ColorStringGreen = 'rgb(162, 184, 108)';
const String ColorStringBlue = 'rgb(19, 149, 186)';
const String ColorStringPurple = 'rgb(13, 60, 85)';
const String ColorStringBrown = 'rgb(217, 78, 32)';

enum PlayerColor {
  White, Black, Red, Orange, Yellow, Green, Blue, Purple, Brown,
}

String stringFromColor(PlayerColor color) {
  switch(color) {
    case PlayerColor.White:
      return ColorStringWhite;
    case PlayerColor.Black:
      return ColorStringBlack;
    case PlayerColor.Red:
      return ColorStringRed;
    case PlayerColor.Orange:
      return ColorStringOrange;
    case PlayerColor.Yellow:
      return ColorStringYellow;
    case PlayerColor.Green:
      return ColorStringGreen;
    case PlayerColor.Blue:
      return ColorStringBlue;
    case PlayerColor.Purple:
      return ColorStringPurple;
    default:
      return ColorStringBrown;
  }
}

class Player {
  int _colorIndex = 0;
  PlayerColor get color => PlayerColor.values[_colorIndex];

  List<Building> buildings = new List<Building>();
  Map<ResourceType, int> resources = new Map<ResourceType, int>();

  Player() {
    ResourceType.values.forEach((type) {
      resources[type] = 0;
    });
  }

  void changeColor([PlayerColor color]) {
    if (color != null) _colorIndex = PlayerColor.values.indexOf(color);
    else _colorIndex = (_colorIndex + 1) % PlayerColor.values.length;
  }

  void addResource(ResourceType type, int cnt) {
    resources[type] = resources[type] + cnt;
  }

  void removeResource(ResourceType type, int cnt) {
    resources[type] = resources[type] - cnt;
  }

  int get count => resources.values.reduce((int prev, int next) => prev + next);
}
