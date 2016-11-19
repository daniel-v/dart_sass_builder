import 'dart:async';

import 'package:build/build.dart';
import 'package:sass/sass.dart' as sass;

class SassBuilder extends Builder {

  @override
  Future build(BuildStep buildStep) async {
    var input = buildStep.input;
    var css = sass.render(input.id.path);
    var cssAsset = new Asset(_toCompiledSassAsset(input.id), css);
    await buildStep.writeAsString(cssAsset);
  }

  @override
  List<AssetId> declareOutputs(AssetId inputId) {
    return [_toCompiledSassAsset(inputId)];
  }

  static AssetId _toCompiledSassAsset(AssetId inputId) => inputId.changeExtension('.css');

  static void addPhases(PhaseGroup group, PackageGraph graph, List<String> globs) {
    group.newPhase().addAction(new SassBuilder(), new InputSet(graph.root.name, globs));
  }
}