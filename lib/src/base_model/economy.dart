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

  Player _payee;
  Player get payee => _payee;

  Player _payer;
  Player get payer => _payer;

  TradePayload({Player payee, Player payer}) : _payee = payee, _payer = payer;

  /// the [trade] function takes # resources from _player and give them to _recipient.
  trade(ResourceType resource, int count) {
    if (resource == null || count <= 0) return false;

    if (!_exchange.containsKey(resource)) _exchange[resource] = 0;
    _exchange[resource] = _exchange[resource] + count;

    if (_payer != null) _payer.removeResource(count, resource);
    if (_payee != null) _payee.addResource(count, resource);

    if (_payer != null) print('Payer ${_payer.color} - ${count} ${resource}');
    if (_payee != null) print('Payee ${_payee.color} + ${count} ${resource}');
  }

  /// the [revoke] function returns any traded resources to the payer.
  void revoke() {
    _exchange.forEach((resource, count) {
      _payer.addResource(count, resource);
      if (_payee != null) _payee.removeResource(count, resource);
      _exchange[resource] = 0;
    });
  }
}

class BuildPayload extends TradePayload {
  PlayerPieceType _piece;
  PlayerPieceType get piece => _piece;

  int _key;
  int get key => _key;

  bool _built = false;
  bool get built => _built;

  BuildPayload(Player player) : super(payer: player);

  build(PlayerPieceType piece, int key) {
    if (_built) return false;

    RATES[piece].forEach((resource, count) {
      _piece = piece;
      _key = key;
      trade(resource, count);
    });

    payer.addPiece(_key, _piece);

    if (_payer != null) print('Build ${_payer.color} + ${_piece} ${_key}');
  }

  @override
  void revoke() {
    payer.removePiece(_key, _piece);
    super.revoke();
  }
}

class RollPayload {
  int roll;

  List<TradePayload> _harvestTrades = new List<TradePayload>();
  List<TradePayload> get harvestTrades => _harvestTrades;

  RollPayload(this.roll);

  harvest(int count, ResourceType resource, Player player) {
    TradePayload payload = new TradePayload(payee: player);
    payload.trade(resource, count);
    _harvestTrades.add(payload);
  }

  void revoke() {
    _harvestTrades.forEach((trade) => trade.revoke());
  }
}

class Economy {
  List<RollPayload> rolls = new List<RollPayload>();
  List<TradePayload> trades = new List<TradePayload>();
  List<BuildPayload> builds = new List<BuildPayload>();

  Board _board;

  Economy(this._board);

  canBuild(PlayerPieceType piece, Player player) {
    bool stillCan = true;
    RATES[piece].forEach((resource, count) {
      stillCan = stillCan && player.resourceCount(resource) >= count;
    });
    return stillCan;
  }

  doBuild(PlayerPieceType piece, int key, Player player) {
    BuildPayload payload = new BuildPayload(player)
      ..build(piece, key);
    builds.insert(0, payload);
    _board._updateBuildingDependentCaches();
  }

  doRoll(int roll) {
    RollPayload payload = new RollPayload(roll);
    _board.tiles.forEach((key, tile) {
      if (tile.roll == roll && key != _board.thiefKey) {
        tile.neighbors(PieceType.Plot).forEach((key) {
          _board.players.forEach((player) {
            Building piece = (player.getPiece(key) as Building);
            if (piece != null) payload.harvest(piece.production, tile.resource, player);
          });
        });
      }
    });
    rolls.insert(0, payload);
  }

  doTrade(TradePayload payload) {
    trades.insert(0, payload);
  }
}
