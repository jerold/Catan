// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var MainMenu = React.registerComponent(() => new _MainMenu());
class _MainMenu extends FluxComponent<GameActions, GameStore> {
  render() {
    String currentState = store.gameState;
    return React.div({'className': 'ui inverted segment'},
      React.div({'className': 'ui inverted menu'}, [
        React.a({
          'className': 'blue item ${currentState == EditingState ? "active" : ""}',
          'onClick': (_) => _handleStateChange(EditingState),
        }, '${currentState == EditingState ? "Editing" : "Edit"}'),
        React.a({
          'className': 'green item ${currentState == PlayingState ? "active" : ""}',
          'onClick': (_) => _handleStateChange(PlayingState),
        }, '${currentState == PlayingState ? "Playing" : "Play"}'),
        React.a({
          'className': 'red item right',
          'onClick': (_) => _handleStartNewGame(),
        }, 'New Game'),
      ])
    );
  }

  _handleStartNewGame() => actions.showNewGameModal(true);

  _handleStateChange(String newState) => actions.changeGameState(newState);
}
