// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var EditingStateSelector = react.registerComponent(() => new _EditingStateSelector());
class _EditingStateSelector extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    String currentState = store.editState;
    return react.div({'className': 'ui horizontal link list'}, [
      react.a({
        'className': 'item ${currentState == BoardSetupState ? "active" : ""}',
        'onClick': (_) => _handleClick(BoardSetupState),
      }, BoardSetupState),
      react.i({'className': 'right chevron icon divider'}),
      react.a({
        'className': 'item ${currentState == PlayerSetupState ? "active" : ""}',
        'onClick': (_) => _handleClick(PlayerSetupState),
      }, PlayerSetupState),
      react.i({'className': 'right chevron icon divider'}),
      react.a({
        'className': 'item ${currentState == PieceSetupState ? "active" : ""}',
        'onClick': (_) => _handleClick(PieceSetupState),
      }, PieceSetupState),
    ]);
  }

  _handleClick(String newState) => actions.changeEditState(newState);
}
