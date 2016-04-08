// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var EditingStateSelector = react.registerComponent(() => new _EditingStateSelector());
class _EditingStateSelector extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    return react.div({'className': 'ui horizontal link list'}, [
      react.a({
        'className': 'item ${store.editState == EditState.BoardSetup ? "active" : ""}',
        'onClick': (_) => _handleClick(EditState.BoardSetup),
      }, BoardSetupState),
      react.i({'className': 'right chevron icon divider'}),
      react.a({
        'className': 'item ${store.editState == EditState.PlayerSetup ? "active" : ""}',
        'onClick': (_) => _handleClick(EditState.PlayerSetup),
      }, PlayerSetupState),
      react.i({'className': 'right chevron icon divider'}),
      react.a({
        'className': 'item ${store.editState == EditState.PieceSetup ? "active" : ""}',
        'onClick': (_) => _handleClick(EditState.PieceSetup),
      }, PieceSetupState),
    ]);
  }

  _handleClick(EditState newState) => actions.setEditState(newState);
}
