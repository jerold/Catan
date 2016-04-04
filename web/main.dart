import 'dart:html';
import 'dart:js';

import 'package:react/react_client.dart' as react_client;
import 'package:react/react_dom.dart' as react_dom;

import 'package:catan/catan.dart';

main() async {
  GameModule module = new GameModule();
  await module.load();

  react_client.setClientConfiguration();

  react_dom.render(module.components.content(), querySelector(SELECTOR_HELPER_COMPONENT));
  react_dom.render(module.components.newGameDimmer(), querySelector(SELECTOR_NEW_GAME_MODAL));
  react_dom.render(module.components.controlPaletteDimmer(), querySelector(SELECTOR_CONTROL_PALETTE_MODAL));

  module.events.showModel.listen((idSelector) {
    context
      .callMethod(r'$', [idSelector])
      .callMethod(r'dimmer', ['show']);
  });

  module.events.hideModel.listen((idSelector) {
    context
      .callMethod(r'$', [idSelector])
      .callMethod(r'dimmer', ['hide']);
  });
}
