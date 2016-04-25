// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class TradePayload {
  Economy _eco;
  Economy get eco => _eco;

  bool _completed = false;
  bool get completed => _completed;

  Map<Resource, int> _exchange = new Map<Resource, int>();
  Map<Resource, int> get exchange => new Map<Resource, int>.from(_exchange);

  Player _payee;
  Player get payee => _payee;

  Player _payer;
  Player get payer => _payer;

  TradePayload(this._eco, {Player payee, Player payer}) : _payee = payee, _payer = payer;

  /// the [deposit] function takes # resources from _player and give them to _recipient.
  deposit(Resource resource, int count) {
    if (resource == null || count <= 0) return;

    if (!_exchange.containsKey(resource)) _exchange[resource] = 0;
    _exchange[resource] = _exchange[resource] + count;

    ResourcePayload payload = new ResourcePayload(count, resource);
    if (_payer != null) _payer.actions.removeResources(payload);
  }

  /// the [withdraw] function returns previously deposited resources to the _player
  withdraw(Resource resource, int count) {
    if (resource == null || count <= 0) return;

    if (!_exchange.containsKey(resource) || _exchange[resource] < count) return;
    _exchange[resource] = _exchange[resource] - count;

    ResourcePayload payload = new ResourcePayload(count, resource);
    if (_payer != null) _payer.actions.addResources(payload);
  }

  /// the [complete] function sends any exchanged resources to the payee.
  complete() {
    if (_completed) return;
    _completed = true;

    _exchange.forEach((resource, count) {
      ResourcePayload payload = new ResourcePayload(count, resource);
      if (_payee != null) _payee.actions.addResources(payload);
    });
  }

  /// the [revoke] function returns any exchanged resources to the payer.
  revoke() {
    _exchange.forEach((resource, count) {
      ResourcePayload payload = new ResourcePayload(count, resource);
      _payer.actions.addResources(payload);
      _exchange[resource] = 0;
    });
  }
}

class BuildPayload extends TradePayload {
  Piece _piece;
  Piece get piece => _piece;

  int _key;
  int get key => _key;

  bool _built = false;
  bool get built => _built;

  BuildPayload(Economy eco, Player player) : super(eco, payer: player);

  build(GamePieceType type, int key) {
    if (_built) return false;

    RATES[type].forEach((resource, count) {
      _key = key;
      deposit(resource, count);
    });
    complete();

    Piece piece = new Piece.ofType(type, key, owner: payer);
    _eco.board.actions.addPiece(piece);

    if (_payer != null) print('Build ${_payer.color} + ${_piece} ${_key}');
  }

  @override
  void revoke() {
    _eco.board.actions.removePiece(_piece);
    super.revoke();
  }
}

class RollPayload {
  Economy _eco;

  int roll;

  List<TradePayload> _harvestTrades = new List<TradePayload>();
  List<TradePayload> get harvestTrades => _harvestTrades;

  RollPayload(this._eco, this.roll);

  addHarvest(Building building, Tile tile) {
    if (building == null || _eco.board.thiefKey == tile.key) return null;
    TradePayload payload = new TradePayload(_eco, payee: building.owner);
    payload
      ..deposit(tile.resource, building.production)
      ..complete();
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
  Board get board => _board;

  Economy(this._board);

  canBuy(GamePieceType piece, Player player) {
    bool stillCan = true;
    print("canBuy ${piece} ${player}");
    RATES[piece].forEach((resource, count) {
      print("  ${player.resourceCount(resource)} >= ${count}");
      stillCan = stillCan && player.resourceCount(resource) >= count;
    });
    return stillCan;
  }

  doBuy(GamePieceType piece, int key, Player player) {
    BuildPayload payload = new BuildPayload(this, player)
      ..build(piece, key);
    builds.insert(0, payload);
    _board._updateBuildingDependentCaches();
  }

  doInitialHarvest(Building building) {
    if (building == null) return null;
    building.neighbors(PieceType.Tile).forEach((tKey) {
      if (_board.tiles.containsKey(tKey) && _board.tiles[tKey] is Tile) {
        Tile tile = _board.tiles[tKey] as Tile;
        if (tile.key != _board.thiefKey) {
          TradePayload payload = new TradePayload(this, payee: building.owner);
          payload.deposit(tile.resource, building.production);
          doTrade(payload);
        }
      }
    });
  }

  doRoll(int roll) {
    RollPayload payload = new RollPayload(this, roll);
    _board.tiles.forEach((key, tile) {
      if (tile.roll == roll && key != _board.thiefKey) {
        tile.neighbors(PieceType.Plot).forEach((key) {
          if (_board.plots.containsKey(key) && _board.plots[key] is Building) {
            Building building = _board.plots[key] as Building;
            payload.addHarvest(building, tile);
          }
        });
      }
    });
    rolls.insert(0, payload);
  }

  doTrade(TradePayload payload) {
    payload.complete();
    trades.insert(0, payload);
  }
}
