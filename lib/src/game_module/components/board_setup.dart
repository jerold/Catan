// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var BoardSetup = react.registerComponent(() => new _BoardSetup());
class _BoardSetup extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    return BoardSvg({'actions': actions, 'store': store});
  }
}
