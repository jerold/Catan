// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class BoardStore extends w_flux.Store {
  GameActions _actions;

  // Board _board;
  // Board get board => _board;

  // Rectangle _viewport = new Rectangle(0, 0, 0, 0);
  // Rectangle get viewport => _viewport;
  //
  // int _activePlayerIndex = 0;
  // int get activePlayerIndex => _activePlayerIndex;
  // Player get activePlayer => _activePlayerIndex < _board.players.length ? _board.players[_activePlayerIndex] : null;
  //
  // int _activeTileKey;
  // int get activeTileKey => _activeTileKey;
  // Tile get activeTile => _board.tiles[_activeTileKey];
  //
  // int _activePlotKey;
  // int get activePlotKey => _activePlotKey;
  //
  // Point _activatePoint = new Point(0,0);
  // Point get activatePoint => _activatePoint;

  BoardStore(this._actions) {
    // _actions
    //   ..addTile.listen(_handleAddTile)
    //   ..removeTile.listen(_handleRemoveTile)
    //
    //   ..addPlayer.listen(_handleAddPlayer)
    //   ..removePlayer.listen(_handleRemovePlayer)
    //
    //   ..setActiveTileRoll.listen(_handleSetActiveTileRoll)
    //   ..setActiveTileTerrain.listen(_handleSetActiveTerrain)
    //
    //   ..setActiveTileKey.listen(_handleSetActiveTileKey)
    //   ..setActivePlotKey.listen(_handleSetActivePlotKey)
    //   ..setActivePlayer.listen(_handleSetActivePlayer)
    //   ..setActivatePoint.listen(_handleSetActivatePoint)
    //
    //   ..build.listen(_handleBuild)
    //   ..harvest.listen(_handleHarvest)
    //
    //   ..moveThief.listen(_handleMoveThief)
    //   ..roll.listen(_handleRoll)
    //
    //   ..startNewGame.listen(_startNewGame);

      // String mapParam = Uri.base.queryParameters['map'];
      // List<String> tileStrings = _splitMapParam(mapParam);
      // if (tileStrings.length > 0) _startNewGameFromURI(tileStrings);
      // else _startNewGame();
  }

  // _startNewGame([_]) {
  //   _board = new Board.standard();
  //   _updateDisplay();
  // }

  // _startNewGameFromURI(List<String> tileStrings) {
  //   List<int> keys = new List<int>();
  //   List<Terrain> types = new List<Terrain>();
  //   List<int> rolls = new List<int>();
  //   tileStrings.forEach((tileString) {
  //     if (tileString.length == 7) {
  //       keys.add(int.parse(tileString.substring(0, 4)));
  //       types.add(tileTypeFromString(tileString.substring(6)));
  //       rolls.add(int.parse(tileString.substring(4, 6)));
  //     }
  //   });
  //   _board = new Board(keys, types, rolls);
  //   _updateDisplay();
  // }

  // _updateDisplay() {
  //   double maxManDist = 0.0;
  //   board.tiles.forEach((_, tile) {
  //     double posX = tile.coordinate.point.x.toDouble().abs();
  //     double posY = tile.coordinate.point.y.toDouble().abs();
  //     if (posX > maxManDist) maxManDist = posX;
  //     if (posY > maxManDist) maxManDist = posY;
  //   });
  //   _viewport = new Rectangle(
  //     -1 * maxManDist - (SPACING_X * 3),
  //     -1 * maxManDist - (SPACING_Y * 3),
  //     2 * maxManDist + (SPACING_X * 6),
  //     2 * maxManDist + (SPACING_Y * 6));
  //
  //   _pushBoardToURI();
  //   trigger();
  // }

  // _pushBoardToURI() {
  //   List<String> mapParam = new List<String>();
  //   board.tiles.values.forEach((tile) {
  //     mapParam.add('${tile.key.toString().padLeft(4, "0")}${tile.roll.toString().padLeft(2, "0")}${stringFromTerrain(tile.terrain)}');
  //   });
  //   Uri current = Uri.base;
  //   Map<String, String> params = new Map<String, String>.from(current.queryParameters);
  //   params['map'] = mapParam.join('');
  //   current = current.replace(queryParameters: params);
  //   window.history.pushState('', '', current.toString());
  // }

  // List<String> _splitMapParam(String mapParam) {
  //   List<String> tileStrings = new List<String>();
  //   if (mapParam != null) {
  //     for (int i = 0; i + 7 <= mapParam.length; i += 7) {
  //       tileStrings.add(mapParam.substring(i, i + 7));
  //     }
  //   }
  //   return tileStrings;
  // }

  // Handle Player Actions

  // _handleAddPlayer(Player player) {
  //   if (board.addPlayer(player)) trigger();
  // }
  //
  // _handleRemovePlayer(Player player) {
  //   if (board.removePlayer(player)) trigger();
  // }

  // _handleSetActivePlayer(Player player) {
  //   _activePlayerIndex = _board.players.indexOf(player);
  //   trigger();
  // }

  // Handle Tile Actions

  // _handleAddTile(int key) {
  //   board.addPiece(new Tile(key));
  //   _updateDisplay();
  // }
  //
  // _handleRemoveTile(int key) {
  //   board.removePiece(board.tiles[key]);
  //   _updateDisplay();
  // }
  //
  // _handleSetActiveTileRoll(int newRoll) {
  //   board.changeTile(activeTile.key, roll: newRoll);
  //   _updateDisplay();
  //   trigger();
  // }
  //
  // _handleSetActiveTerrain(Terrain newTerrain) {
  //   board.changeTile(activeTileKey, terrain: newTerrain);
  //   _updateDisplay();
  //   trigger();
  // }

  // _handleSetActiveTileKey(int tileKey) {
  //   _activeTileKey = tileKey;
  //   trigger();
  // }
  //
  // _handleSetActivePlotKey(int plotKey) {
  //   _activePlotKey = plotKey;
  //   trigger();
  // }
  //
  // _handleSetActivatePoint(Point newPoint) {
  //   _activatePoint = newPoint;
  // }

  _handleBuild(GamePieceType pieceType) {
    if (activePlayer == null) return;
    if (_board.economy.canBuy(pieceType, activePlayer)) {
      _board.economy.doBuy(pieceType, activePlotKey, activePlayer);
      trigger();
    } else {
      print('WARNING!!! Player ${activePlayer.color} can not afford a ${pieceType}');
    }
  }

  _handleHarvest(_) {
    if (activePlotKey == null) return;
    if (_board.plots.containsKey(activePlotKey) && _board.plots[activePlotKey] is Building) {
      Building building = _board.plots[activePlotKey] as Building;
      _board.economy.doInitialHarvest(building);
    } else {
      print('WARNING!!! No building at ${activePlotKey} from which to harvest');
    }
    trigger();
  }

  _handleMoveThief(_) {
    if (activeTile != null) {
      board.thiefKey = activeTile.key;
      trigger();
    }
  }

  _handleRoll(int roll) {
    _board.economy.doRoll(roll);
    trigger();
  }
}
