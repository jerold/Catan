part of catan.game_module;

class EdgeControlPaletteConfig extends ControlPaletteConfig {
  factory EdgeControlPaletteConfig(
      int edge, GameActions actions, GameStore store) {
    List<PaletteOption> options = [
      new PaletteOption(
          'road',
          () => store.board.actions.purchase(new PurchasePayload(
              edge, GamePieceType.Road, store.board.activePlayer))),
    ];
    return new EdgeControlPaletteConfig._internal(options);
  }

  EdgeControlPaletteConfig._internal(List<PaletteOption> options)
      : super(options);
}
