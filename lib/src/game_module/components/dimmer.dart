// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Dimmer = react.registerComponent(() => new _Dimmer());
class _Dimmer extends w_flux.FluxComponent<GameActions, GameStore> {

  DimmerType get currentDimmer => state['currentDimmer'];

  getInitialState() => stateFromStore();

  stateFromStore() => {
    'currentDimmer': store.currentDimmer,
  };

  setStateFromStore() => setState(stateFromStore());

  Map<w_flux.Store, Function> getStoreHandlers() => { store: (_) => setStateFromStore() };

  bool shouldComponentUpdate(_, nextState) => nextState['currentDimmer'] != currentDimmer;

  render() {
    if (currentDimmer == DimmerType.TileOptions) {
      return ControlPalette({'actions': actions, 'store': store});
    } else if (currentDimmer == DimmerType.ConfirmNewGame) {
      return ConfirmNewGame({'actions': actions, 'store': store});
    }
  }
}
