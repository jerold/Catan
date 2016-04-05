// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Dimmer = react.registerComponent(() => new _Dimmer());
class _Dimmer extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    if (!store.confirmNewGameDimmerVisible) return ControlPalette({'actions': actions, 'store': store});
    else return ConfirmNewGame({'actions': actions, 'store': store});
  }
}
