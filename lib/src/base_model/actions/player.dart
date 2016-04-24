// Copyright (c) 2015, Jerold Albertson. All rights reserved.

part of catan.base_model;


class PlayerActions {
  w_flux.Action<ResourcePayload> addResources = new w_flux.Action<ResourcePayload>();
  w_flux.Action<ResourcePayload> removeResources = new w_flux.Action<ResourcePayload>();
  w_flux.Action<String> changeColor = new w_flux.Action<String>();
  w_flux.Action<String> changeName = new w_flux.Action<String>();
}
