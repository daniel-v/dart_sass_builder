import 'dart:async';

import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/visitor/perform.dart';
import 'package:sass/src/visitor/serialize.dart';

String _renderScss(String contents, {Uri url, bool color: false}) {
  var sassTree = new Stylesheet.parseScss(contents, url: url, color: color);
  var cssTree = evaluate(sassTree, color: color);
  return toCss(cssTree);
}

class SassBuilder extends Builder {

  @override
  Future build(BuildStep buildStep) async {
    var input = buildStep.input;
    var url = p.toUri(input.id.path);
    var css = _renderScss(input.stringContents, url: url);
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