part of catan.game_module;

var MainMenu = react.registerComponent(() => new _MainMenu());

class _MainMenu extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    return react.div(
        {'className': 'ui inverted segment'},
        react.div({
          'className': 'ui inverted menu'
        }, [
          react.a({
            'className':
                'blue item ${store.gameState == GameState.Editing ? "active" : ""}',
            'onClick': (_) => _handleStateChange(GameState.Editing),
          }, '${store.gameState == GameState.Editing ? "Editing" : "Edit"}'),
          react.a({
            'className':
                'green item ${store.gameState == GameState.Playing ? "active" : ""}',
            'onClick': (_) => _handleStateChange(GameState.Playing),
          }, '${store.gameState == GameState.Playing ? "Playing" : "Play"}'),
          react.a({
            'className': 'red item right',
            'onClick': (_) => _handleStartNewGame(),
          }, 'New Game'),
        ]));
  }

  _handleStartNewGame() => actions.showDimmer(DimmerType.ConfirmNewGame);

  _handleStateChange(GameState newState) => actions.setGameState(newState);
}
