part of catan.game_module;

class GameActions {
  w_flux.Action<Point> setInteractionPoint = new w_flux.Action<Point>();

  w_flux.Action startNewGame = new w_flux.Action();

  w_flux.Action<EditState> setEditState = new w_flux.Action<EditState>();
  w_flux.Action<GameState> setGameState = new w_flux.Action<GameState>();
  w_flux.Action<DimmerType> showDimmer = new w_flux.Action<DimmerType>();
  w_flux.Action hideDimmer = new w_flux.Action();
}
