import 'package:yaml/yaml.dart' as yaml;

class YamlBuilderConfig {
  final String directoryPath;
  final List<String> fileGlobs;
  final YamlSassConfig sassConfig;

  YamlBuilderConfig(this.directoryPath, this.fileGlobs, this.sassConfig);

  factory YamlBuilderConfig.fromYaml(yaml.YamlMap config, String path) {
    return new YamlBuilderConfig(
        path, new List.unmodifiable(config['files']), new YamlSassConfig.fromYaml(config['sass']));
  }

  @override
  String toString() {
    return 'Config:\n\tfiles: $fileGlobs\n\tsass:$sassConfig';
  }
}

class YamlSassConfig {
  final SassBuilderKinds builder;
  final List<String> arguments;

  YamlSassConfig(this.builder, {this.arguments});

  factory YamlSassConfig.fromYaml(yaml.YamlMap config) {
    SassBuilderKinds builder = BUILDER_BY_STRING[(config['builder'] as String)?.toLowerCase()];
    if (builder == null) {
      throw new ArgumentError('Unknown builder: `${config['builder']}`. Valid values are: dart, binary');
    }
    List<String> arguments;
    if (config['arguments'] != null) {
      arguments = new List.unmodifiable(config['arguments']);
    }
    return new YamlSassConfig(builder, arguments: arguments);
  }

  @override
  String toString() => '$builder, $arguments';
}

enum SassBuilderKinds {
  DART,
  BINARY
}

const BUILDER_BY_STRING = const <String, SassBuilderKinds>{
  'dart': SassBuilderKinds.DART,
  'binary': SassBuilderKinds.BINARY
};
