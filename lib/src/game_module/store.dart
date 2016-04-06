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

  BoardStore _boardStore;
  BoardStore get boardStore => _boardStore;

  String gameState = EditingState;
  String editState = BoardSetupState;

  int _activePlayerIndex = 0;
  Player get activePlayer => boardStore.board.players[_activePlayerIndex % boardStore.board.players.length];

  ControlPaletteConfig paletteConfig;

  bool dimmerVisible = false;
  bool confirmNewGameDimmerVisible = false;
  bool controlPaletteDimmerVisible = false;

  GameStore(this._actions, this._events, this._dispatch) {
    _actions
      ..changeEditState.listen(_handleChangeEditState)
      ..changeGameState.listen(_handleChangeGameState)

      ..configureControlPalette.listen(_handleConfigControlPalette)

      ..showNewGameDimmer.listen(_handleShowNewGameDimmer)
      ..showControlPaletteDimmer.listen(_handleShowControlPaletteDimmer)
      ..dimmerVisibilitySet.listen(_handleDimmerVisibilitySet);

    _boardStore = new BoardStore(_actions, _events, _dispatch);
  }

  // Handle Dimmer Actions

  _handleShowNewGameDimmer(bool show) {
    confirmNewGameDimmerVisible = show;
    _events.setDimmerVisibility(show, _dispatch);
  }

  _handleShowControlPaletteDimmer(bool show) {
    controlPaletteDimmerVisible = show;
    _events.setDimmerVisibility(show, _dispatch);
  }

  _handleDimmerVisibilitySet(bool isVisible) {
    dimmerVisible = isVisible;
    trigger();
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
}
