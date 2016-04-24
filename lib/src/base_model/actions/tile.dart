// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class TileActions {
  w_flux.Action<int> setRoll = new w_flux.Action<int>();
  w_flux.Action<Terrain> setTerrain = new w_flux.Action<Terrain>();
}
