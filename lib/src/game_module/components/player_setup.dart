// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var PlayerSetup = react.registerComponent(() => new _PlayerSetup());
class _PlayerSetup extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.board];
    else return [];
  }

  render() {
    List<Player> players = new List<Player>.from(board.players);
    List<String> addableColors = new List<String>.from(PlayerColors.where((color) {
      return !board.playerInGame(color);
    }));

    List addItems = new List.from(addableColors.map((color) {
      List<String> classes = ['tiny', color, 'ui', 'button'];
      return react.button({
        'className': classes.join(' '),
        'onClick': (_) => board.actions.addPlayer(new Player(color)),
      }, react.i({'className': 'add user icon'}));
    }));

    int turn = 1;
    List removeItems = new List.from(players.map((player) {
      List<String> classes = ['tiny', 'ui', player.color, 'button'];
      return react.a({
        'className': classes.join(' '),
        'onClick': (_) => board.actions.removePlayer(player),
      }, [react.i({'className': 'remove user icon'}), ' P${turn++}']);
    }));

    return react.div({'className': 'ui center aligned basic segment'}, [
      react.div({'className': 'ui icon buttons'}, addItems),
      react.div({'className': 'ui horizontal divider'}, 'Add Players'),
      react.div({'className': ''}, removeItems),
    ]);
  }
}
