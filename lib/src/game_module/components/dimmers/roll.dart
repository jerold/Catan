// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


final List<int> ROLLS = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
final int ROBBED_ROLL = 7;

var Roll = react.registerComponent(() => new _Roll());
class _Roll extends w_flux.FluxComponent<GameActions, GameStore> {

  int get selected => state['selected'];

  getInitialState() => {'selected': 0};

  render() {
    List rolls = new List.from(ROLLS.map((roll) {
      return react.button({
          'className': 'ui inverted ${roll == selected ? "active" : ""} button',
          'onClick': (_) => _select(roll),
      }, '${roll}');
    }));

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.i({'className':'cube icon'}),
          react.div({'className': 'segment'}, [
            'Roll',
          ]),
          react.div({'className':'sub header'}, [
            react.div({'className': 'ui basic segment'}, rolls),
            react.div({'className': 'ui hidden divider'}),
            react.div({'className': 'ui basic segment'}, [
              react.button({
                  'className': 'ui red basic cancel inverted button',
                  'onClick': _handleCancel,
              }, react.i({'className': 'remove icon'})),
              react.button({
                  'className': 'ui green ok inverted button',
                  'onClick': _handleConfirm,
              }, react.i({'className': 'checkmark icon'}))
            ])
          ])
        ])
      ])
    ]);
  }

  _select(int value) {
    setState({'selected': value});
  }

  _handleCancel(_) {
    actions.hideDimmer();
  }

  _handleConfirm(_) {
    if (selected == ROBBED_ROLL) {
      bool getRobbed = store.board.players.any((player) => player.handCount > 7);
      if (getRobbed) actions.showDimmer(DimmerType.GetRobbed);
      else actions.hideDimmer();
    } else if (ROLLS.contains(selected)) {
      store.board.actions.roll(selected);
      actions.hideDimmer();
    }
  }
}
