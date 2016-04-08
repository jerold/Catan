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

enum DimmerType { ConfirmNewGame, TileOptions, PlotOptions, Roll, Trade, None }
enum GameState { Editing, Playing }
enum EditState { BoardSetup, PlayerSetup, PieceSetup }

class GameStore extends w_flux.Store {
  w_module.DispatchKey _dispatch;
  GameActions _actions;
  GameEvents _events;

  BoardStore _boardStore;
  BoardStore get boardStore => _boardStore;

  GameState gameState = GameState.Editing;
  EditState editState = EditState.BoardSetup;

  bool _dimmerVisible = false;
  bool get dimmerVisible => _dimmerVisible;

  DimmerType _currentDimmer = DimmerType.None;
  DimmerType get currentDimmer => _currentDimmer;

  GameStore(this._actions, this._events, this._dispatch) {
    _actions
      ..setEditState.listen(_handleSetEditState)
      ..setGameState.listen(_handleSetGameState)

      ..showDimmer.listen(_handleShowDimmer)
      ..hideDimmer.listen(_handleHideDimmer);

    _boardStore = new BoardStore(_actions, _events, _dispatch);
  }

  // Handle Dimmer Actions

  _handleShowDimmer(DimmerType newDimmer) {
    _currentDimmer = newDimmer;
    _events.setDimmerVisibility(true, _dispatch);
    trigger();
  }

  _handleHideDimmer(_) {
    _currentDimmer = DimmerType.None;
    _events.setDimmerVisibility(false, _dispatch);
    trigger();
  }

  // Handle State Actions

  _handleSetEditState(EditState newState) {
    editState = newState;
    trigger();
  }

  _handleSetGameState(GameState newState) {
    gameState = newState;
    trigger();
  }
}
