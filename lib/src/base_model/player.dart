// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;

class Player {
  int _colorIndex = 0;
  String get color => PlayerColors[_colorIndex];

  List<Building> buildings = new List<Building>();
  Map<ResourceType, int> resources = new Map<ResourceType, int>();

  Player(String color) {
    changeColor(color);
    ResourceType.values.forEach((type) {
      resources[type] = 0;
    });
  }

  void changeColor([String color]) {
    if (color != null) _colorIndex = PlayerColors.indexOf(color);
    else _colorIndex = (_colorIndex + 1) % PlayerColors.length;
  }

  void addResource(ResourceType type, int cnt) {
    resources[type] = resources[type] + cnt;
  }

  void removeResource(ResourceType type, int cnt) {
    resources[type] = resources[type] - cnt;
  }

  int get handCount => resources.values.reduce((int prev, int next) => prev + next);
}
