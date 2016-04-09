// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Players = react.registerComponent(() => new _Players());
class _Players extends w_flux.FluxComponent<GameActions, GameStore> {

  componentDidMount(rootNode) {
    super.componentDidMount(rootNode);
    // context
    //   .callMethod(r'$', ['.ui.dropdown'])
    //   .callMethod(r'dropdown', []);
  }

  render() {
    List playerItems = new List();
    store.boardStore.board.players.forEach((player) {
      playerItems.add(react.div({
        'className': 'ui tiny ${player.color} icon button',
        'onClick': (_) => actions.setActivePlayer(player),
      }, [
        react.i({'className': 'user icon'}),
        player == store.boardStore.activePlayer ? react.span({'className': 'text'}, '${player.color}') : null,
      ]));

      // playerItems.add(react.div({
      //     'className': 'ui tiny floating dropdown ${player.color} icon button',
      //     'onClick': (_) => actions.setActivePlayer(player),
      // }, [
      //   react.i({'className': 'user icon'}),
      //   react.span({'className': 'text'}, '${player.color}'),
      //   react.div({'className': 'menu'}, [
      //     react.div({'className': 'item'}, 'resource A'),
      //     react.div({'className': 'item'}, 'resource B'),
      //     react.div({'className': 'item'}, 'resource C'),
      //   ]),
      // ]));
    });
    return react.div({}, playerItems);
  }
}
