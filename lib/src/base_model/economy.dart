// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class TradePayload extends w_flux.Store {
  Economy _eco;
  Economy get eco => _eco;

  bool _completed = false;
  bool get completed => _completed;

  Map<Commodity, int> _exchange = new Map<Commodity, int>();
  Map<Commodity, int> get exchange => new Map<Commodity, int>.from(_exchange);

  int get total => _exchange.values.fold(0, (sum, next) => sum + next);

  Player _payee;
  Player get payee => _payee;

  Player _payer;
  Player get payer => _payer;

  int _quota;
  int get quota => _quota;

  TradePayload(this._eco, {Player payee, Player payer, int quota}) : _payee = payee, _payer = payer, _quota = quota ?? 0;

  /// the [deposit] function takes # commodities from _player and give them to _recipient.
  deposit(Commodity commodity, int count) {
    if (commodity == null || count <= 0) return;

    if (!_exchange.containsKey(commodity)) _exchange[commodity] = 0;
    _exchange[commodity] = _exchange[commodity] + count;

    CommodityPayload payload = new CommodityPayload(count, commodity);
    if (_payer != null) _payer.actions.removeCommodities(payload);
    trigger();
  }

  /// the [withdraw] function returns previously deposited commodities to the _player
  withdraw(Commodity commodity, int count) {
    if (commodity == null || count <= 0) return;

    if (!_exchange.containsKey(commodity) || _exchange[commodity] < count) return;
    _exchange[commodity] = _exchange[commodity] - count;

    CommodityPayload payload = new CommodityPayload(count, commodity);
    if (_payer != null) _payer.actions.addCommodities(payload);
    trigger();
  }

  /// the [requiresSatisfaction] function is true if quota is greater than 0.
  bool requiresSatisfaction() => _quota > 0;

  /// the [canComplete] function is typically true, unless the trade has a deposit
  /// quota, and that quota isn't met.
  bool canComplete() => _quota == 0 || total == _quota;

  /// the [complete] function sends any exchanged commodities to the payee.
  complete() {
    if (_completed) return;
    _completed = true;

    _exchange.forEach((commodity, count) {
      CommodityPayload payload = new CommodityPayload(count, commodity);
      if (_payee != null) _payee.actions.addCommodities(payload);
    });
    trigger();
  }

  /// the [revoke] function returns any exchanged commodities to the payer.
  revoke() {
    _exchange.forEach((commodity, count) {
      CommodityPayload payload = new CommodityPayload(count, commodity);
      if (_payer != null) _payer.actions.addCommodities(payload);
      _exchange[commodity] = 0;
    });
    trigger();
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

    RATES[type].forEach((commodity, count) {
      _key = key;
      deposit(commodity, count);
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
      ..deposit(tile.commodity, building.production)
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
    RATES[piece].forEach((commodity, count) {
      print("  ${player.commodityCount(commodity)} >= ${count}");
      stillCan = stillCan && player.commodityCount(commodity) >= count;
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
          payload.deposit(tile.commodity, building.production);
          doTrade(payload);
        }
      }
    });
  }

  doRoll(int roll) {
    RollPayload payload = new RollPayload(this, roll);
    _board.tiles.forEach((key, tile) {
      if (tile is Tile) {
        if (tile.roll == roll && key != _board.thiefKey) {
          tile.neighbors(PieceType.Plot).forEach((key) {
            if (_board.plots.containsKey(key) && _board.plots[key] is Building) {
              Building building = _board.plots[key] as Building;
              payload.addHarvest(building, tile);
            }
          });
        }
      }
    });
    rolls.insert(0, payload);
  }

  doTrade(TradePayload payload) {
    if (payload != null && payload.total > 0) {
      payload.complete();
      trades.insert(0, payload);
    }
  }
}
