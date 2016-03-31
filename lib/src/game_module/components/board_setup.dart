// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var BoardSetup = React.registerComponent(() => new _BoardSetup());
class _BoardSetup extends FluxComponent<GameActions, GameStore> {
  render() {
    return BoardSvg({'actions': actions, 'store': store});
  }
}
