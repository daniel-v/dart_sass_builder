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
    String scss = await buildStep.readAsString(buildStep.input.id);
    String css = await compilationStrategy.compile(buildStep.input.id, scss);
    Asset output = new Asset(toCompiledSassAsset(buildStep.input.id), css);
    buildStep.writeAsString(output);
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