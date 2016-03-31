// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var EditingStateSelector = React.registerComponent(() => new _EditingStateSelector());
class _EditingStateSelector extends FluxComponent<GameActions, GameStore> {
  render() {
    String currentState = store.editState;
    return React.div({'className': 'ui horizontal link list'}, [
      React.a({
        'className': 'item ${currentState == BoardSetupState ? "active" : ""}',
        'onClick': (_) => _handleClick(BoardSetupState),
      }, BoardSetupState),
      React.i({'className': 'right chevron icon divider'}),
      React.a({
        'className': 'item ${currentState == PlayerSetupState ? "active" : ""}',
        'onClick': (_) => _handleClick(PlayerSetupState),
      }, PlayerSetupState),
      React.i({'className': 'right chevron icon divider'}),
      React.a({
        'className': 'item ${currentState == PieceSetupState ? "active" : ""}',
        'onClick': (_) => _handleClick(PieceSetupState),
      }, PieceSetupState),
    ]);
  }

  _handleClick(String newState) => actions.changeEditState(newState);
}
