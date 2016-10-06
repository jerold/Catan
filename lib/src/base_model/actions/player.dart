part of catan.base_model;

class PlayerActions {
  w_flux.Action<CommodityPayload> addCommodities =
      new w_flux.Action<CommodityPayload>();
  w_flux.Action<CommodityPayload> removeCommodities =
      new w_flux.Action<CommodityPayload>();
  w_flux.Action<String> changeColor = new w_flux.Action<String>();
  w_flux.Action<String> changeName = new w_flux.Action<String>();
}
