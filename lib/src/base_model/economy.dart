// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


final Map<PlayerPieceType, Map<ResourceType, int>> RATES = new Map<PlayerPieceType, Map<ResourceType, int>>()
  ..[PlayerPieceType.Road] = {
    ResourceType.Lumber: 1,
    ResourceType.Brick: 1,
  }
  ..[PlayerPieceType.Settlement] = {
    ResourceType.Lumber: 1,
    ResourceType.Brick: 1,
    ResourceType.Wheat: 1,
    ResourceType.Sheep: 1,
  }
  ..[PlayerPieceType.City] = {
    ResourceType.Ore: 3,
    ResourceType.Wheat: 2,
  };


class TradePayload {
  Map<ResourceType, int> _exchange = new Map<ResourceType, int>();
  Map<ResourceType, int> get exchange => new Map<ResourceType, int>.from(_exchange);

  Player _player;
  Player get player => _player;

  TradePayload(this._player);

  bool deposit(ResourceType resource, int count) {
    if (_player.has(resource, count)) {
      if (!_exchange.containsKey(resource)) _exchange[resource] = 0;
      _exchange[resource] = _exchange[resource] + count;
      _player.take(resource, count);
      return true;
    }
    return false;
  }

  /// The [cancel] function returns deposit to the player
  void cancel() {
    _exchange.forEach((resource, count) => _player.give(resource, count));
  }

  /// The [complete] function gives the deposit to a recipient or returns it to the void.
  void complete([Player recipient]) {
    if (recipient != null) {
      _exchange.forEach((resource, count) => recipient.give(resource, count));
    }
  }
}

class Economy {
  Board _board;

  Economy(this._board);

  canAfford(PlayerPieceType pieceType, Player player) {
    bool stillCan = true;
    RATES[pieceType].forEach((resource, count) {
      stillCan = stillCan && player.has(resource, count);
    });
    return stillCan;
  }

  doBuy(PlayerPieceType pieceType, Player player) {
    RATES[pieceType].forEach((resource, count) => player.take(resource, count));
  }

  doTrade(TradePayload dis, [TradePayload dat]) {
    dis.complete(dat?.player);
    dat?.complete(dis.player);
  }
}
