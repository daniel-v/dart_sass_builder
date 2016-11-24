import 'dart:async';

import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/visitor/perform.dart';
import 'package:sass/src/visitor/serialize.dart';

AssetId _toCompiledSassAsset(AssetId inputId) => inputId.changeExtension('.css');

abstract class CompilationStrategy {
  Future<Asset> compile(Asset asset);
}

class DartSassCompilationStrategy implements CompilationStrategy {

  @override
  Future<Asset> compile(Asset asset) async {
    String outputCss = _renderScss(asset.stringContents, url: p.toUri(asset.id.path), color: false);
    return new Asset(_toCompiledSassAsset(asset.id), outputCss);
  }

  static String _renderScss(String contents, {Uri url, bool color: false}) {
    var sassTree = new Stylesheet.parseScss(contents, url: url, color: color);
    var cssTree = evaluate(sassTree, color: color);
    return toCss(cssTree);
  }
}

class SassBuilder extends Builder {

  final CompilationStrategy _compilationStrat;

  SassBuilder([CompilationStrategy compilationStrategy])
      : _compilationStrat = compilationStrategy ?? new DartSassCompilationStrategy();

  @override
  Future build(BuildStep buildStep) async {
    var cssAsset = await _compilationStrat.compile(buildStep.input);
    await buildStep.writeAsString(cssAsset);
  }

  @override
  List<AssetId> declareOutputs(AssetId inputId) {
    return [_toCompiledSassAsset(inputId)];
  }

  static void addPhases(PhaseGroup group, PackageGraph graph, List<String> globs) {
    group.newPhase().addAction(new SassBuilder(), new InputSet(graph.root.name, globs));
  }
}