import 'dart:async';
import 'dart:io';
import 'builder_config.dart';
import 'package:build/build.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as p;

import '../sass_builder.dart';

const configFileName = 'sass_builder.yaml';

File getConfigFile(Directory inDirectory) {
  var configFileUri = inDirectory.uri.resolve(configFileName);
  final configFile = new File.fromUri(configFileUri);
  if (configFile.existsSync())
    return configFile;
  stdout.writeln('WARNING: config file not found: ${configFileUri.path}');
  return null;
}

YamlBuilderConfig readConfig(File config) {
  yaml.YamlNode node = yaml.loadYamlNode(config.readAsStringSync());
  if (node is yaml.YamlMap) {
    return new YamlBuilderConfig.fromYaml(node, p.dirname(config.path));
  } else {
    throw new UnsupportedError('Invalid configuration. Please see the documentation for `sass_builder.yaml`');
  }
}

Future<BuildResult> compileSass(YamlBuilderConfig config) async {
  PackageGraph graph = new PackageGraph.forPath(config.directoryPath);
  var phases = new PhaseGroup();
  SassBuilder.addPhases(phases, graph, config.fileGlobs);
  return await build(phases, deleteFilesByDefault: true);
}
