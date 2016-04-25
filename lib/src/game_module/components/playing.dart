// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Playing = react.registerComponent(() => new _Playing());
class _Playing extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.board];
    else return [];
  }

  Player get activePlayer => state['activePlayer'];

  getInitialState() => stateFromStore()..['renaming'] = false;

  stateFromStore() => {'activePlayer': store.activePlayer};

  setStateFromStore() => setState(stateFromStore());

  Map<w_flux.Store, Function> getStoreHandlers() => {
    store: (_) => setStateFromStore(),
  };

  render() {
    return react.div({'className': 'ui basic vertical center aligned segment'}, [
      Players({'actions': actions, 'store': store}),

      react.div({'className': 'ui horizontal divider'}, [
        react.span({'style': {
          'color': store.activePlayer?.color,
        }}, '${store.activePlayer?.name ?? "Player"}\'s turn'),
      ]),

      // react.div({'className': 'ui horizontal divider'}, '${store.activePlayer?.name ?? "Player"}\'s turn'),
      BoardSvg({'actions': actions, 'store': store}),
      CurrentTurnOptions({'actions': actions, 'store': store}),
      react.div({'className': 'ui horizontal divider'}, 'History'),
      HistoryList({'actions': actions, 'store': store}),
    ]);
  }
}
