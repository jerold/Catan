// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Players = react.registerComponent(() => new _Players());
class _Players extends w_flux.FluxComponent<GameActions, GameStore> {

  componentDidMount(rootNode) {
    super.componentDidMount(rootNode);

    // context
    //   .callMethod(r'$', ['.ui.button.player'])
    //   .callMethod(r'popup', []);

    context
      .callMethod(r'$', ['.ui.dropdown'])
      .callMethod(r'dropdown', []);
  }

  render() {
    List playerItems = new List();
    store.boardStore.board.players.forEach((player) {
      // playerItems.add(react.div({'className': 'ui segment'}, [
        // react.div({'className': 'ui ${player.color} icon button player'}, [
        //   react.i({'className': 'user icon'}),
        //   react.span({'className': 'text'}, '${player.color}'),
        // ]),
      //   react.div({'className': 'ui fluid basic popup bottom center transition hidden'}, [
      //     react.h4({'className': 'ui header'}, 'resource A'),
      //     react.p({'className': 'text'}, 'resource B'),
      //     react.div({'className': 'text'}, 'resource C'),
      //   ])
      // ]));
      // playerItems.add(react.div({'className': 'ui ${player.color} icon button player'}, [
      //   react.i({'className': 'user icon'}),
      //   react.span({'className': 'text'}, '${player.color}'),
      // ]));
      // playerItems.add(react.div({'className': 'ui fluid basic popup bottom center transition hidden'}, [
      //   react.h4({'className': 'ui header'}, 'resource A'),
      //   react.p({'className': 'text'}, 'resource B'),
      //   react.div({'className': 'text'}, 'resource C'),
      // ]));

      playerItems.add(react.div({'className': 'ui tiny floating dropdown ${player.color} icon button'}, [
        react.i({'className': 'user icon'}),
        react.span({'className': 'text'}, '${player.color}'),
        react.div({'className': 'menu'}, [
          react.div({'className': 'item'}, 'resource A'),
          react.div({'className': 'item'}, 'resource B'),
          react.div({'className': 'item'}, 'resource C'),
        ]),
      ]));
    });
    return react.div({}, playerItems);
  }
}
