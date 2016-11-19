import 'dart:async';

import 'dart:io';
import 'package:build/build.dart';
import 'package:package_config/packages.dart';
import 'package:path/path.dart' as p;
import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/visitor/perform.dart';
import 'package:sass/src/visitor/serialize.dart';
import 'package:package_config/discovery.dart';

Future<String> _renderScss(String contents, {Uri url, bool color: false, List<String> loadPaths}) async {
  var sassTree = new Stylesheet.parseScss(contents, url: url, color: color);
  var cssTree = evaluate(sassTree, loadPaths: loadPaths, color: color);
  return toCss(cssTree);
}

class SassBuilder extends Builder {

  @override
  Future build(BuildStep buildStep) async {
    var input = buildStep.input;
    var url = p.toUri(input.id.path);
    var packages = await _dependencies;
    var paths = packages.asMap().values.map((Uri uri) => uri.toFilePath()).toList();
    var css = await _renderScss(input.stringContents, url: url, loadPaths: paths);
    var cssAsset = new Asset(_toCompiledSassAsset(input.id), css);
    await buildStep.writeAsString(cssAsset);
  }

  @override
  List<AssetId> declareOutputs(AssetId inputId) {
    return [_toCompiledSassAsset(inputId)];
  }

  Future<Packages> get _dependencies async {
    // let's cache
    if(_packages == null) {
      _packages = await findPackages(Platform.script);
    }
    return _packages;
  }

  Packages _packages;

  static AssetId _toCompiledSassAsset(AssetId inputId) => inputId.changeExtension('.css');

  static void addPhases(PhaseGroup group, PackageGraph graph, List<String> globs) {
    group.newPhase().addAction(new SassBuilder(), new InputSet(graph.root.name, globs));
  }
}