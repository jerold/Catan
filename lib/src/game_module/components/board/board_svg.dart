// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var BoardSvg = react.registerComponent(() => new _BoardSvg());
class _BoardSvg extends w_flux.FluxComponent<GameActions, GameStore> {
  render() {
    List children = new List();

    // Expansions
    children.add(WaterGroup({'actions': actions, 'store': store}));
    // if (store.gameState == EditingState && store.editState == BoardSetupState) {
    //   children.add(WaterGroup({'actions': actions, 'store': store}));
    // }

    // Tiles
    store.gameBoard.tiles.values.forEach((tile) {
      children.add(TileGroup({
        'actions': actions,
        'store': store,
        'tile': tile}));
    });

    // Plots
    if (store.gameState == EditingState && store.editState == PieceSetupState) {
      children.add(PlotGroup({'actions': actions, 'store': store}));
    }

    Rectangle viewBox = new Rectangle(
      store.viewport.left * COORD_SPACING,
      store.viewport.top * COORD_SPACING,
      store.viewport.width * COORD_SPACING,
      store.viewport.height * COORD_SPACING
    );

    return react.svg({
      'version': '1.1',
      'xmlns': 'http://www.w3.org/2000/svg',
      'width': viewBox.width,
      'height': viewBox.height,
      'viewBox': '${viewBox.left} ${viewBox.top} ${viewBox.width} ${viewBox.height}',
      'style': {
        'WebkitTouchCallout': 'none',
        'WebkitUserSelect': 'none',
        'KhtmlUserSelect': 'none',
        'MozUserSelect': 'none',
        'MsUserSelect': 'none',
        'userSelect': 'none',
      }
    }, children);
  }
}
