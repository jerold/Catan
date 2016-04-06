// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var BoardSvg = react.registerComponent(() => new _BoardSvg());
class _BoardSvg extends w_flux.FluxComponent<GameActions, GameStore> {

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.boardStore];
    else return [];
  }

  render() {
    List children = new List();

    // Expansions
    children.add(WaterGroup({'actions': actions, 'store': store}));

    // Tiles
    store.boardStore.board.tiles.values.forEach((tile) {
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
      store.boardStore.viewport.left * COORD_SPACING,
      store.boardStore.viewport.top * COORD_SPACING,
      store.boardStore.viewport.width * COORD_SPACING,
      store.boardStore.viewport.height * COORD_SPACING
    );

    return react.svg({
      'version': '1.1',
      'xmlns': 'http://www.w3.org/2000/svg',
      'width': viewBox.width,
      'height': viewBox.height,
      'viewBox': '${viewBox.left} ${viewBox.top} ${viewBox.width} ${viewBox.height}',
    }, children);
  }
}
