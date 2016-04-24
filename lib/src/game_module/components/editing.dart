// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Editing = react.registerComponent(() => new _Editing());
class _Editing extends w_flux.FluxComponent<GameActions, GameStore> {

  Player get activePlayer => state['activePlayer'];
  EditState get editState => state['editState'];

  getInitialState() => stateFromStore();

  stateFromStore() => {
    'activePlayer': store.activePlayer,
    'editState': store.editState,
  };

  setStateFromStore() => setState(stateFromStore());

  Map<w_flux.Store, Function> getStoreHandlers() => {
    store: (_) => setStateFromStore(),
    // store.board: (_) => setStateFromStore()
  };

  bool shouldComponentUpdate(_, nextState) {
    return nextState['activePlayer'] != activePlayer
      || nextState['editState'] != editState;
  }

  render() {
    List editItems = new List();
    editItems.add(EditingStateSelector({'actions': actions, 'store': store}));
    editItems.add(react.div({'className': 'ui hidden divider'}));

    if (editState == EditState.PieceSetup) {
      editItems.add(Players({'actions': actions, 'store': store}));
      editItems.add(react.div({'className': 'ui horizontal divider'}, [
        react.span({'style': {
          'color': activePlayer?.color,
        }}, '${activePlayer != null ? activePlayer.color : ""} '),
        'Player active'
      ]));
    }

    if (editState == EditState.BoardSetup || editState == EditState.PieceSetup) {
      editItems.add(BoardSetup({'actions': actions, 'store': store}));
    } else if (editState == EditState.PlayerSetup) {
      editItems.add(PlayerSetup({'actions': actions, 'store': store}));
    }

    return react.div({'className': 'ui basic vertical center aligned segment'}, editItems);
  }
}
