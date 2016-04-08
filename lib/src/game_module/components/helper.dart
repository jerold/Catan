// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Helper = react.registerComponent(() => new _Helper());
class _Helper extends w_flux.FluxComponent<GameActions, GameStore> {

  GameState get gameState => state['gameState'];

  getInitialState() => stateFromStore();

  stateFromStore() => {
    'gameState': store.gameState,
  };

  setStateFromStore() => setState(stateFromStore());

  Map<w_flux.Store, Function> getStoreHandlers() => { store: (_) => setStateFromStore() };

  bool shouldComponentUpdate(_, nextState) => nextState['gameState'] != gameState;

  render() {
    List items = new List();
    items.add(MainMenu({'actions': actions, 'store': store}));
    if (gameState == GameState.Playing) {
      items.add(Playing({'actions': actions, 'store': store}));
    } else {
      items.add(Editing({'actions': actions, 'store': store}));
    }

    return react.div({'className': 'content'}, items);
  }
}
