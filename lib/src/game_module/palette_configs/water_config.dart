part of catan.game_module;

class WaterControlPaletteConfig extends ControlPaletteConfig {
  factory WaterControlPaletteConfig(
      int tileKey, GameActions actions, GameStore store) {
    List<PaletteOption> options = new List<PaletteOption>();

    if (store.gameState == GameState.Editing) {
      options.add(new PaletteOption(
          'map', () => store.board.actions.addPiece(new Tile(tileKey))));
      options.add(new PaletteOption(
          'anchor', () => store.board.actions.addPiece(new Port(tileKey))));
    }

    return new WaterControlPaletteConfig._internal(options);
  }

  WaterControlPaletteConfig._internal(List<PaletteOption> options)
      : super(options);
}
