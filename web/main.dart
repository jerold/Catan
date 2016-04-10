import 'dart:html';

import 'package:react/react_client.dart' as react_client;
import 'package:react/react_dom.dart' as react_dom;

import 'package:catan/catan.dart';

// setDimmerVisibility(bool visibility) {
//   context.callMethod(r'$', [SELECTOR_DIMMER]).callMethod(r'dimmer', [visibility ? 'show' : 'hide']);
// }

main() async {
  GameModule module = new GameModule();
  await module.load();

  react_client.setClientConfiguration();

  react_dom.render(module.components.content(), querySelector(SELECTOR_CONTENT));
  react_dom.render(module.components.dimmer(), querySelector(SELECTOR_DIMMER));
}
