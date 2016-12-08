import 'dart:io';
import 'package:sass_builder/executable.dart';

main(List<String> args) async {
  File configFile = getConfigFile(Directory.current);
  if (configFile != null) {
    YamlBuilderConfig config = readConfig(configFile);
    compileSass(config);
  } else {
    print('No sass_builder.yaml config file found');
  }
}