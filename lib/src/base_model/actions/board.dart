part of catan.base_model;

class BoardActions {
  w_flux.Action<Piece> addPiece = new w_flux.Action<Piece>();
  w_flux.Action<Piece> removePiece = new w_flux.Action<Piece>();

  w_flux.Action<Player> addPlayer = new w_flux.Action<Player>();
  w_flux.Action<Player> removePlayer = new w_flux.Action<Player>();

  w_flux.Action<int> setActiveKey = new w_flux.Action<int>();
  w_flux.Action<Player> setActivePlayer = new w_flux.Action<Player>();

  w_flux.Action<int> setActiveTileRoll = new w_flux.Action<int>();
  w_flux.Action<Terrain> setActiveTileTerrain = new w_flux.Action<Terrain>();
  w_flux.Action rotateActivePort = new w_flux.Action();

  w_flux.Action<PurchasePayload> purchase =
      new w_flux.Action<PurchasePayload>();
  w_flux.Action<Building> harvest = new w_flux.Action<Building>();
  w_flux.Action<int> moveThief = new w_flux.Action<int>();
  w_flux.Action<int> roll = new w_flux.Action<int>();
}
