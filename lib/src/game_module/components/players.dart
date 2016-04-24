// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Players = react.registerComponent(() => new _Players());
class _Players extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.board];
    else return [];
  }

  render() {
    List playerItems = new List();
    board.players.forEach((player) {
      playerItems.add(react.div({
        'className': 'ui tiny ${player.color} icon button',
        'onClick': (_) => actions.setActivePlayer(player),
      }, [
        react.i({'className': 'user icon'}),
        player == store.activePlayer ? react.span({'className': 'text'}, '${player.color}') : null,
      ]));
    });
    return react.div({}, playerItems);
  }
}
