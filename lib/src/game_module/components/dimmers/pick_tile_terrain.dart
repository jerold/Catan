// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var PickTerrain = react.registerComponent(() => new _PickTerrain());
class _PickTerrain extends w_flux.FluxComponent<GameActions, GameStore> {
  Tile get tile => (store.board.activePiece as Tile);

  Terrain get selected => state['selected'];

  getInitialState() => {'selected': tile.terrain};

  render() {
    List terrains = new List.from(TERRAINS.map((terrain) {
      return react.button({
          'className': 'ui inverted ${terrain == selected ? "active" : ""} button',
          'onClick': (_) => _select(terrain),
      }, '${stringFromTerrain(terrain)}');
    }));

    return react.div({'className':'content'}, [
      react.div({'className':'center'}, [
        react.h2({'className':'ui inverted icon header'}, [
          react.i({'className':'theme icon'}),
          react.div({'className': 'segment'}, [
            'Tile Terrain',
          ]),
          react.div({'className':'sub header'}, [
            react.div({'className': 'ui basic segment'}, terrains),
            react.div({'className': 'ui hidden divider'}),
            react.div({'className': 'ui basic segment'}, [
              react.button({
                  'className': 'ui red basic cancel inverted button',
                  'onClick': _handleCancel,
              }, react.i({'className': 'remove icon'}))
            ])
          ])
        ])
      ])
    ]);
  }

  _select(Terrain value) {
    if (TERRAINS.contains(value)) store.board.actions.setActiveTileTerrain(value);
    actions.hideDimmer();
  }

  _handleCancel(_) {
    actions.hideDimmer();
  }
}
