// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var MainMenu = react.registerComponent(() => new _MainMenu());
class _MainMenu extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    String currentState = store.gameState;
    return react.div({'className': 'ui inverted segment'},
      react.div({'className': 'ui inverted menu'}, [
        react.a({
          'className': 'blue item ${currentState == EditingState ? "active" : ""}',
          'onClick': (_) => _handleStateChange(EditingState),
        }, '${currentState == EditingState ? "Editing" : "Edit"}'),
        react.a({
          'className': 'green item ${currentState == PlayingState ? "active" : ""}',
          'onClick': (_) => _handleStateChange(PlayingState),
        }, '${currentState == PlayingState ? "Playing" : "Play"}'),
        react.a({
          'className': 'red item right',
          'onClick': (_) => _handleStartNewGame(),
        }, 'New Game'),
      ])
    );
  }

  _handleStartNewGame() => actions.showNewGameModal(true);

  _handleStateChange(String newState) => actions.changeGameState(newState);
}
