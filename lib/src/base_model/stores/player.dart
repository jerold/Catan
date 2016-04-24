// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Player extends w_flux.Store {
  PlayerActions _actions = new PlayerActions();
  PlayerActions get actions => _actions;

  int _colorIndex = 0;
  String get color => PlayerColors[_colorIndex];

  String _name = '';
  String get name => _name;

  Map<Resource, int> _resources = new Map<Resource, int>();
  Map<Resource, int> get resources => new Map<Resource, int>.from(_resources);

  Player(String color) {
    _changeColor(color);

    // start with no resources
    RESOURCES.forEach((resource) => _resources[resource] = 0);

    // Add initial funds required to buy two settlements
    RATES[GamePieceType.Settlement].forEach((resource, count) => _resources[resource] = count * 2);

    triggerOnAction(_actions.addResources, _addResource);
    triggerOnAction(_actions.removeResources, _removeResource);
    triggerOnAction(_actions.changeColor, _changeColor);
    triggerOnAction(_actions.changeName, _changeName);
  }

  _changeColor([String color]) {
    if (color != null && PlayerColors.indexOf(color) >= 0) _colorIndex = PlayerColors.indexOf(color);
    else _colorIndex = (_colorIndex + 1) % PlayerColors.length;
  }

  _changeName(String newName) => this._name = newName ?? this._name;

  // Resource Helpers

  void _addResource(ResourcePayload payload) {
    _resources[payload.resource] = _resources[payload.resource] + payload.count;
  }

  void _removeResource(ResourcePayload payload) {
    _resources[payload.resource] = _resources[payload.resource] - payload.count;
  }

  bool hasResource(int count, Resource resource) => _resources[resource] >= count;

  int resourceCount(Resource resource) => _resources[resource];

  int get handCount => resources.values.reduce((int prev, int next) => prev + next);
}
