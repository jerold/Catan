part of catan.game_module;

var Players = react.registerComponent(() => new _Players());

class _Players extends w_flux.FluxComponent<GameActions, Board> {
  Board get board => store;

  Player get activePlayer => state['activePlayer'];
  String get name => state['name'];
  bool get renaming => state['renaming'];

  getInitialState() => stateFromBoard()..['renaming'] = false;

  stateFromBoard() => {
        'activePlayer': board.activePlayer,
        'name': board.activePlayer?.name ?? '',
      };

  setStateFromBoard() => setState(stateFromBoard());

  Map<w_flux.Store, Function> getStoreHandlers() =>
      {store: (_) => setStateFromBoard()};

  render() {
    List players = new List();
    board.players.forEach((player) {
      List playerItems = new List();
      playerItems.add(react.i({'className': 'user icon'}));
      if (player == activePlayer)
        playerItems.add(react.span({'className': 'text'}, ' ${player.name}'));
      players.add(react.div({
        'className': 'ui ${player.color} icon button',
        'onClick': (_) => board.actions.setActivePlayer(player),
        'onDoubleClick': _onDoubleClick,
      }, playerItems));
    });

    if (renaming) {
      players.add(react.div({
        'className': 'ui left icon action input'
      }, [
        react.i({'className': '${activePlayer.color} user icon'}),
        react.input({
          'type': 'text',
          'value': name,
          'onChange': _onChange,
          'onKeyDown': _onKeyDown,
        }),
        react.div({
          'className': 'ui submit button',
          'onClick': _changeName,
        }, 'Change Name'),
      ]));
    }

    return react.div({
      'className': ''
    }, [
      react.div({'className': 'ui small input'}, players),
    ]);
  }

  _onDoubleClick(_) {
    setState({'renaming': !renaming});
  }

  _onKeyDown(react.SyntheticKeyboardEvent event) {
    if (event.keyCode == KeyCode.ENTER) _changeName();
    if (event.keyCode == KeyCode.ESC) setState({'renaming': false});
  }

  _onChange(react.SyntheticFormEvent event) {
    setState({'name': event.target.value});
  }

  _changeName([_]) async {
    await activePlayer.actions.changeName(name);
    setState({'renaming': false});
  }
}
