// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;


var BoardSvg = react.registerComponent(() => new _BoardSvg());
class _BoardSvg extends w_flux.FluxComponent<GameActions, GameStore> {
  Board get board => store.board;

  @override
  List<w_flux.Store> redrawOn() {
    if (store is GameStore) return [store.board];
    else return [];
  }

  render() {
    List children = new List();

    // Expansions
    children.add(WaterGroup({'actions': actions, 'store': store}));

    // Tiles
    board.tiles.values.forEach((tile) {
      children.add(TileGroup({
        'actions': actions,
        'store': store,
        'tile': tile}));
    });

    // Plots
    if (store.gameState == GameState.Editing && store.editState == EditState.PieceSetup) {
      children.add(PlotGroup({'actions': actions, 'store': store}));
    }

    // Buildings
    children.add(BuildingGroup({'actions': actions, 'store': store}));

    Rectangle viewBox = new Rectangle(
      board.boundingRect.left * COORD_SPACING,
      board.boundingRect.top * COORD_SPACING,
      board.boundingRect.width * COORD_SPACING,
      board.boundingRect.height * COORD_SPACING
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
