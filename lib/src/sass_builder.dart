import 'dart:async';

import 'package:build/build.dart';
import 'compilation_strategies.dart';
import 'util.dart';

class SassBuilder extends Builder {

  final CompilationStrategy compilationStrategy;

  SassBuilder([CompilationStrategy compilationStrategy])
      : compilationStrategy = compilationStrategy ?? new DartSassCompilationStrategy();

  @override
  Future build(BuildStep buildStep) async {
    var cssAsset = await compilationStrategy.compile(buildStep.input);
    buildStep.writeAsString(cssAsset);
  }

  @override
  List<AssetId> declareOutputs(AssetId inputId) {
    return [toCompiledSassAsset(inputId)];
  }

  static void addPhases(PhaseGroup group,
      PackageGraph graph,
      List<String> globs,
      {CompilationStrategy compiler}) {
    group.newPhase().addAction(new SassBuilder(compiler), new InputSet(graph.root.name, globs));
  }
}