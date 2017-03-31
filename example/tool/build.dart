import 'dart:async';

import 'package:build_runner/build_runner.dart';
import 'package:sass_builder/sass_builder.dart';

Future main() async {
  var graph = new PackageGraph.forThisPackage();
  var phases = new PhaseGroup();

  // This is where the actual SASS magic happens
  SassBuilder.addPhases(phases, graph, ['web/*.scss']);

  await build(phases);
}