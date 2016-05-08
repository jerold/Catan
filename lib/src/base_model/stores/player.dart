// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class Player extends w_flux.Store {
  PlayerActions _actions = new PlayerActions();
  PlayerActions get actions => _actions;

  int _colorIndex = 0;
  String get color => PlayerColors[_colorIndex];

  String _name = '';
  String get name => _name;

  Map<Commodity, int> _commodities = new Map<Commodity, int>();
  Map<Commodity, int> get commodities => new Map<Commodity, int>.from(_commodities);

  Player(String color) {
    _changeColor(color);
    _changeName(color);

    // start with no commodities
    COMMODITIES.forEach((commodity) => _commodities[commodity] = 0);

    // Add initial funds required to buy two settlements and two roads
    RATES[GamePieceType.Settlement].forEach((commodity, count) {
      _commodities[commodity] = _commodities[commodity] + (count * 2);
    });
    RATES[GamePieceType.Road].forEach((commodity, count) {
      _commodities[commodity] = _commodities[commodity] + (count * 2);
    });

    triggerOnAction(_actions.addCommodities, _addCommodity);
    triggerOnAction(_actions.removeCommodities, _removeCommodity);
    triggerOnAction(_actions.changeColor, _changeColor);
    triggerOnAction(_actions.changeName, _changeName);
  }

  _changeColor([String color]) {
    if (color != null && PlayerColors.indexOf(color) >= 0) _colorIndex = PlayerColors.indexOf(color);
    else _colorIndex = (_colorIndex + 1) % PlayerColors.length;
  }

  _changeName(String newName) => this._name = newName ?? this._name;

  // Commodity Helpers

  void _addCommodity(CommodityPayload payload) {
    _commodities[payload.commodity] = _commodities[payload.commodity] + payload.count;
    print('Payer ${color} + ${payload.count} ${payload.commodity} (${_commodities[payload.commodity]})');
  }

  void _removeCommodity(CommodityPayload payload) {
    _commodities[payload.commodity] = _commodities[payload.commodity] - payload.count;
    print('Payer ${color} - ${payload.count} ${payload.commodity} (${_commodities[payload.commodity]})');
  }

  int commodityCount(Commodity commodity) => _commodities[commodity];

  int get handCount => commodities.values.reduce((int prev, int next) => prev + next);
}
