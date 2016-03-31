// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var PlayerSetup = React.registerComponent(() => new _PlayerSetup());
class _PlayerSetup extends FluxComponent<GameActions, GameStore> {
  render() {
    List<Player> players = new List<Player>.from(store.gameBoard.players);
    List<String> addableColors = new List<String>.from(PlayerColors.where((color) {
      return !store.playerInGame(color);
    }));

    List addItems = new List.from(addableColors.map((color) {
      List<String> classes = ['tiny', color, 'ui', 'button'];
      return React.button({
        'className': classes.join(' '),
        'onClick': (_) => actions.addPlayer(new Player(color)),
      }, React.i({'className': 'add user icon'}));
    }));

    int turn = 1;
    List removeItems = new List.from(players.map((player) {
      List<String> classes = ['tiny', 'ui', player.color, 'button'];
      return React.a({
        'className': classes.join(' '),
        'onClick': (_) => actions.removePlayer(player),
      }, [React.i({'className': 'remove user icon'}), ' Player ${turn++}']);
    }));

    return React.div({'className': 'ui center aligned basic segment'}, [
      React.div({'className': 'ui icon buttons'}, addItems),
      React.div({'className': 'ui horizontal divider'}, 'Add Players'),
      React.div({'className': ''}, removeItems),
    ]);
  }
}
