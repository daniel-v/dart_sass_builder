import 'dart:async';

import 'package:build/build.dart';
import 'package:sass_builder/sass_builder.dart';

Future main() async {
  var graph = new PackageGraph.forThisPackage();
  var phases = new PhaseGroup();

  // This is where the actual SASS magic happens
  SassBuilder.addPhases(phases, graph, ['lib/*.scss']);

  await build(phases);
}