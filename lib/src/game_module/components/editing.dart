// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

var Editing = react.registerComponent(() => new _Editing());
class _Editing extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    List editItems = new List();
    editItems.add(EditingStateSelector({'actions': actions, 'store': store}));
    editItems.add(react.div({'className': 'ui hidden divider'}));

    if (store.editState == BoardSetupState || store.editState == PieceSetupState) {
      editItems.add(BoardSetup({'actions': actions, 'store': store}));
    } else if (store.editState == PlayerSetupState) {
      editItems.add(PlayerSetup({'actions': actions, 'store': store}));
    }
    
    return react.div({'className': 'ui basic center aligned segment'}, editItems);
  }
}
