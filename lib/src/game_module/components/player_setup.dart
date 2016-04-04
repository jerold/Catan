// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var PlayerSetup = react.registerComponent(() => new _PlayerSetup());
class _PlayerSetup extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    List<Player> players = new List<Player>.from(store.gameBoard.players);
    List<String> addableColors = new List<String>.from(PlayerColors.where((color) {
      return !store.playerInGame(color);
    }));

    List addItems = new List.from(addableColors.map((color) {
      List<String> classes = ['tiny', color, 'ui', 'button'];
      return react.button({
        'className': classes.join(' '),
        'onClick': (_) => actions.addPlayer(new Player(color)),
      }, react.i({'className': 'add user icon'}));
    }));

    int turn = 1;
    List removeItems = new List.from(players.map((player) {
      List<String> classes = ['tiny', 'ui', player.color, 'button'];
      return react.a({
        'className': classes.join(' '),
        'onClick': (_) => actions.removePlayer(player),
      }, [react.i({'className': 'remove user icon'}), ' Player ${turn++}']);
    }));

    return react.div({'className': 'ui center aligned basic segment'}, [
      react.div({'className': 'ui icon buttons'}, addItems),
      react.div({'className': 'ui horizontal divider'}, 'Add Players'),
      react.div({'className': ''}, removeItems),
    ]);
  }
}
