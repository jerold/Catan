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

enum DimmerType {
  ConfirmNewGame,
  TileOptions,
  PickTileRoll,
  PickTileTerrain,
  PlotOptions,
  WaterOptions,
  Roll,
  Trade,
  None,
}
enum GameState { Editing, Playing }
enum EditState { BoardSetup, PlayerSetup, PieceSetup }
enum PlayState { Roll, Trade, Build }

class GameStore extends w_flux.Store {
  GameActions _actions;

  Board _board;
  Board get board => _board;

  // Active Pieces & Player

  int _activePlayerIndex = 0;
  int get activePlayerIndex => _activePlayerIndex;
  Player get activePlayer => _activePlayerIndex < _board.players.length ? _board.players[_activePlayerIndex] : null;

  int _activeTileKey;
  int get activeTileKey => _activeTileKey;
  Tile get activeTile => _board.tiles[_activeTileKey];

  int _activePlotKey;
  int get activePlotKey => _activePlotKey;

  Point _activatePoint = new Point(0,0);
  Point get activatePoint => _activatePoint;

  // UI Properties

  GameState gameState = GameState.Editing;
  EditState editState = EditState.BoardSetup;

  bool _dimmerVisible = false;
  bool get dimmerVisible => _dimmerVisible;

  DimmerType _currentDimmer = DimmerType.None;
  DimmerType get currentDimmer => _currentDimmer;

  GameStore(this._actions) {
    String mapParam = Uri.base.queryParameters['map'];
    List<String> tileStrings = _splitMapParam(mapParam);
    if (tileStrings.length > 0) _startNewGameFromURI(tileStrings);
    else _startNewGame();

    triggerOnAction(_actions.setActivatePoint, _setActivatePoint);
    triggerOnAction(_actions.setActivePlayer, _setActivePlayer);
    triggerOnAction(_actions.setActivePlotKey, _setActivePlotKey);
    triggerOnAction(_actions.setActiveTileKey, _setActiveTileKey);

    triggerOnAction(_actions.startNewGame, _startNewGame);

    triggerOnAction(_actions.setEditState, _setEditState);
    triggerOnAction(_actions.setGameState, _setGameState);
    triggerOnAction(_actions.showDimmer, _showDimmer);
    triggerOnAction(_actions.hideDimmer, _hideDimmer);

    _board.listen(_pushBoardToURI);
  }

  _startNewGame([_]) {
    gameState = GameState.Editing;
    editState = EditState.BoardSetup;

    _board = new Board.standard();
  }

  _startNewGameFromURI(List<String> tileStrings) {
    List<int> keys = new List<int>();
    List<Terrain> types = new List<Terrain>();
    List<int> rolls = new List<int>();
    tileStrings.forEach((tileString) {
      if (tileString.length == 7) {
        keys.add(int.parse(tileString.substring(0, 4)));
        types.add(tileTypeFromString(tileString.substring(6)));
        rolls.add(int.parse(tileString.substring(4, 6)));
      }
    });

    _board = new Board(keys, types, rolls);
  }

  _pushBoardToURI([_]) {
    List<String> mapParam = new List<String>();
    board.tiles.values.forEach((tile) {
      mapParam.add('${tile.key.toString().padLeft(4, "0")}${tile.roll.toString().padLeft(2, "0")}${stringFromTerrain(tile.terrain)}');
    });
    Uri current = Uri.base;
    Map<String, String> params = new Map<String, String>.from(current.queryParameters);
    params['map'] = mapParam.join('');
    current = current.replace(queryParameters: params);
    window.history.pushState('', '', current.toString());
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

  // Handle Set Active Actions

  _setActivePlayer(Player player) => _activePlayerIndex = _board.players.indexOf(player);

  _setActiveTileKey(int tileKey) => _activeTileKey = tileKey;

  _setActivePlotKey(int plotKey) => _activePlotKey = plotKey;

  _setActivatePoint(Point newPoint) => _activatePoint = newPoint;

  // Handle UI State Actions

  _setEditState(EditState newState) => editState = newState;

  _setGameState(GameState newState) => gameState = newState;

  // Handle UI Dimmer Actions

  _showDimmer(DimmerType newDimmer) {
    _currentDimmer = newDimmer;
    _dimmerVisible = true;
  }

  _hideDimmer(_) {
    _currentDimmer = DimmerType.None;
    _dimmerVisible = false;
  }
}
