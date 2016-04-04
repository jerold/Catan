import 'dart:html';
import 'dart:js';

import 'package:react/react_client.dart' as react_client;
import 'package:react/react_dom.dart' as react_dom;

import 'package:catan/catan.dart';

main() async {
  GameModule module = new GameModule();
  await module.load();

  react_client.setClientConfiguration();
  react_dom.render(module.components.content(), querySelector('#content'));
  react_dom.render(module.components.palette(), querySelector('#control-palette'));

  module.events.showPaletteModel.listen((_) {
    context
      .callMethod(r'$', ['#control-palette'])
      .callMethod(r'modal', ['show']);
  });

  module.events.hidePaletteModel.listen((_) {
    context
      .callMethod(r'$', ['#control-palette'])
      .callMethod(r'modal', ['hide']);
  });
}
