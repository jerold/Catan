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

enum DimmerType { ConfirmNewGame, TileOptions, PlotOptions, WaterOptions, Roll, Trade, None }
enum GameState { Editing, Playing }
enum EditState { BoardSetup, PlayerSetup, PieceSetup }
enum PlayState { Roll, Trade, Build }

class GameStore extends w_flux.Store {
  GameActions _actions;

  BoardStore _boardStore;
  BoardStore get boardStore => _boardStore;

  GameState gameState = GameState.Editing;
  EditState editState = EditState.BoardSetup;

  bool _dimmerVisible = false;
  bool get dimmerVisible => _dimmerVisible;

  DimmerType _currentDimmer = DimmerType.None;
  DimmerType get currentDimmer => _currentDimmer;

  GameStore(this._actions) {
    _actions
      ..setEditState.listen(_handleSetEditState)
      ..setGameState.listen(_handleSetGameState)

      ..showDimmer.listen(_handleShowDimmer)
      ..hideDimmer.listen(_handleHideDimmer);

    _boardStore = new BoardStore(_actions);
  }

  // Handle Dimmer Actions

  _handleShowDimmer(DimmerType newDimmer) {
    _currentDimmer = newDimmer;
    _dimmerVisible = true;
    trigger();
  }

  _handleHideDimmer(_) {
    _currentDimmer = DimmerType.None;
    _dimmerVisible = false;
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
