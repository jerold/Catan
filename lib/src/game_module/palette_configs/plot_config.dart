// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class PlotControlPaletteConfig extends ControlPaletteConfig {
  factory PlotControlPaletteConfig(int plot, GameActions actions, GameStore store) {
    List<PaletteOption> options = [
      // new PaletteOption(
      //   'road',
      //   () => store.board.actions.purchase(new PurchasePayload(plot, GamePieceType.Road, store.board.activePlayer))),
      new PaletteOption(
        'home',
        () => store.board.actions.purchase(new PurchasePayload(plot, GamePieceType.Settlement, store.board.activePlayer))),
      new PaletteOption(
        'university',
        () => store.board.actions.purchase(new PurchasePayload(plot, GamePieceType.City, store.board.activePlayer))),
    ];
    return new PlotControlPaletteConfig._internal(options);
  }

  PlotControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
