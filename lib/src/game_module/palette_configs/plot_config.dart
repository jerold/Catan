// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.game_module;

class PlotControlPaletteConfig extends ControlPaletteConfig {
  factory PlotControlPaletteConfig(int plot, GameActions actions, GameStore store) {
    List<PaletteOption> options = [
      new PaletteOption(
        'road',
        () => store.board.actions.purchase(new PurchasePayload(plot, GamePieceType.Road, store.activePlayer))),
      new PaletteOption(
        'home',
        () => store.board.actions.purchase(new PurchasePayload(plot, GamePieceType.Settlement, store.activePlayer))),
      new PaletteOption(
        'university',
        () => store.board.actions.purchase(new PurchasePayload(plot, GamePieceType.City, store.activePlayer))),
    ];
    return new PlotControlPaletteConfig._internal(options);
  }

  PlotControlPaletteConfig._internal(List<PaletteOption> options) : super(options);
}
