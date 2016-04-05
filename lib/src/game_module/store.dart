// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

// Primary Helper States
const String EditingState = 'Editing';
const String PlayingState = 'Playing';

// Editing Sub States
const String BoardSetupState = 'Board Setup';
const String PlayerSetupState = 'Player Setup';
const String PieceSetupState = 'Piece Setup';

const String SELECTOR_CONTENT = '#helper-content';
const String SELECTOR_DIMMER = '#helper-dimmer';

class GameStore extends w_flux.Store {
  w_module.DispatchKey _dispatch;

  GameActions _actions;
  GameEvents _events;

  Board gameBoard;

  Rectangle viewport = new Rectangle(0, 0, 0, 0);

  String gameState = EditingState;
  String editState = BoardSetupState;

  int _activePlayerIndex = 0;
  Player get activePlayer => gameBoard.players[_activePlayerIndex % gameBoard.players.length];

  Tile activeTile;

  ControlPaletteConfig paletteConfig;

  bool dimmerVisible = false;
  bool confirmNewGameDimmerVisible = false;
  bool controlPaletteDimmerVisible = false;

  GameStore(this._actions, this._events, this._dispatch) {
    _actions
      ..addTile.listen(_handleAddTile)
      ..removeTile.listen(_handleRemoveTile)
      ..addPlayer.listen(_handleAddPlayer)
      ..removePlayer.listen(_handleRemovePlayer)

      ..changeEditState.listen(_handleChangeEditState)
      ..changeGameState.listen(_handleChangeGameState)

      ..changeActiveTile.listen(_handleChangeActiveTile)
      ..changeActiveTileRoll.listen(_handleChangeActiveTileRoll)
      ..changeActiveTileType.listen(_handleChangeActiveTileType)

      ..startNewGame.listen(_handleStartNewGame)
      ..configureControlPalette.listen(_handleConfigControlPalette)

      ..showNewGameDimmer.listen(_handleShowNewGameDimmer)
      ..showControlPaletteDimmer.listen(_handleShowControlPaletteDimmer)
      ..dimmerVisibilitySet.listen(_handleDimmerVisibilitySet);

    this.listen(_pushBoardToURI);

    String mapParam = Uri.base.queryParameters['map'];
    List<String> tileStrings = _splitMapParam(mapParam);
    if (tileStrings.length > 0) _pullBoardFromURI(tileStrings);
    else _newBoard();
  }

  List<String> _splitMapParam(String mapParam) {
    List<String> tileStrings = new List<String>();
    if (mapParam != null) {
      for (int i = 0; i + 7 <= mapParam.length; i += 7) {
        tileStrings.add(mapParam.substring(i, i + 7));
      }
    }
    return tileStrings;
  }

  _newBoard() {
    gameBoard = new Board.standard();

    _updateViewport();
    trigger();
  }

  _pullBoardFromURI(List<String> tileStrings) {
    List<int> keys = new List<int>();
    List<TileType> types = new List<TileType>();
    List<int> rolls = new List<int>();
    tileStrings.forEach((tileString) {
      if (tileString.length == 7) {
        keys.add(int.parse(tileString.substring(0, 4)));
        types.add(tileTypeFromString(tileString.substring(6)));
        rolls.add(int.parse(tileString.substring(4, 6)));
      }
    });
    gameBoard = new Board(keys, types, rolls);

    _updateViewport();
    trigger();
  }

  _pushBoardToURI(_) {
    List<String> mapParam = new List<String>();
    gameBoard.tiles.values.forEach((tile) {
      mapParam.add('${tile.key.toString().padLeft(4, "0")}${tile.roll.toString().padLeft(2, "0")}${stringFromTileType(tile.type)}');
    });
    Uri current = Uri.base;
    Map<String, String> params = new Map<String, String>.from(current.queryParameters);
    params['map'] = mapParam.join('');
    current = current.replace(queryParameters: params);
    window.history.pushState('', '', current.toString());
  }

  // Handle Player Actions

  _handleAddPlayer(Player player) {
    if (gameBoard.addPlayer(player)) trigger();
  }

  _handleRemovePlayer(Player player) {
    if (gameBoard.removePlayer(player)) trigger();
  }

  // Handle Tile Actions

  _handleAddTile(int key) {
    if (gameBoard.addTile(key)) {
      _updateViewport();
      trigger();
    }
  }

  _handleRemoveTile(int key) {
    if (gameBoard.removeTile(key)) {
      _updateViewport();
      trigger();
    }
  }

  _handleChangeActiveTileRoll(int newRoll) {
    if (activeTile != null) {
      gameBoard.changeTile(activeTile.key, newRoll: newRoll);
      trigger();
    }
  }

  _handleChangeActiveTileType(TileType newType) {
    if (activeTile != null) {
      gameBoard.changeTile(activeTile.key, newType: newType);
      trigger();
    }
  }

  // Handle Dimmer Actions

  _handleShowNewGameDimmer(bool show) {
    confirmNewGameDimmerVisible = show;
    _handleDimmerVisibility(show);
  }

  _handleShowControlPaletteDimmer(bool show) {
    controlPaletteDimmerVisible = show;
    _handleDimmerVisibility(show);
  }

  _handleDimmerVisibility(bool show) {
    _events.setDimmerVisibility(show, _dispatch);
  }

  _handleDimmerVisibilitySet(bool isVisible) {
    dimmerVisible = isVisible;
    trigger();
  }

  _handleStartNewGame(_) {
    _newBoard();
  }

  _handleConfigControlPalette(ControlPaletteConfig newConfig) {
    paletteConfig = newConfig;
    trigger();
  }

  // Handle State Actions

  _handleChangeEditState(String newState) {
    editState = newState;
    trigger();
  }

  _handleChangeGameState(String newState) {
    gameState = newState;
    trigger();
  }

  // Handle Active Change Actions

  _handleChangeActiveTile(Tile newActiveTile) {
    activeTile = newActiveTile;
    trigger();
  }

  // Utility Methods

  _updateViewport() {
    double maxManDist = 0.0;
    gameBoard.tiles.forEach((_, tile) {
      double posX = tile.coordinate.point.x.toDouble().abs();
      double posY = tile.coordinate.point.y.toDouble().abs();
      if (posX > maxManDist) maxManDist = posX;
      if (posY > maxManDist) maxManDist = posY;
    });
    viewport = new Rectangle(
      -1 * maxManDist - (SPACING_X * 3),
      -1 * maxManDist - (SPACING_Y * 3),
      2 * maxManDist + (SPACING_X * 6),
      2 * maxManDist + (SPACING_Y * 6));
  }

  bool playerInGame(String playerColor) {
    bool playerFound = false;
    gameBoard.players.forEach((player) {
      if (player.color == playerColor) playerFound = true;
    });
    return playerFound;
  }
}
