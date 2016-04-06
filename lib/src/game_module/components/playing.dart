// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Playing = react.registerComponent(() => new _Playing());
class _Playing extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    return react.div({'className': 'ui basic vertical center aligned segment'}, [
      Players({'actions': actions, 'store': store}),
      react.div({'className': 'ui horizontal divider'}, 'Player 1\'s turn'),
      BoardSvg({'actions': actions, 'store': store}),
      react.div({'className': 'ui horizontal divider'}, 'History'),
      History({'actions': actions, 'store': store}),
    ]);
  }
}
