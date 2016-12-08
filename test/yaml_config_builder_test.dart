@TestOn("vm")
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:sass_builder/src/executable/builder_config.dart';
import 'package:mockito/mockito.dart';

class MockYamlSassConfig extends Mock implements YamlSassConfig {}

main() {
  group('YamlSassConfig', () {
    test('sets dart builder properly', () {
      final config = 'builder: DarT';
      YamlMap node = loadYamlNode(config);
      var sassConfig = new YamlSassConfig.fromYaml(node);
      expect(sassConfig.builder, SassBuilderKinds.DART);
    });

    test('sets binary builder properly', () {
      final config = 'builder: binary';
      YamlMap node = loadYamlNode(config);
      var sassConfig = new YamlSassConfig.fromYaml(node);
      expect(sassConfig.builder, SassBuilderKinds.BINARY);
      expect(sassConfig.arguments, isNull);
    });

    test('sets binary with config', () {
      final config = '''
sass:
  builder: binary
  arguments:
  - arg1
  - arg2''';
      YamlMap node = loadYamlNode(config);
      var sassConfig = new YamlSassConfig.fromYaml(node['sass']);
      expect(sassConfig.builder, SassBuilderKinds.BINARY);
      expect(sassConfig.arguments, const isInstanceOf<List>());
      expect(sassConfig.arguments, hasLength(2));
      expect(sassConfig.arguments, allOf(contains('arg1'), contains('arg2')));
    });

    test('throws for unknown builder', () {
      final config = 'builder: somethingelse';
      YamlMap node = loadYamlNode(config);
      expect(() {
        new YamlSassConfig.fromYaml(node);
      }, throws);
    });

    test('can invoke toString()', () {
      var config = new YamlSassConfig(SassBuilderKinds.DART, arguments: ['arg1']);
      expect(config.toString(), 'SassBuilderKinds.DART, [arg1]');
    });
  });

  group('YamlBuilderConfig', () {
    final yaml = '''
sass:
  builder: dart
  arguments:
files:
- web/*.scss
''';
    test('builds from yaml', () {
      var config = new YamlBuilderConfig.fromYaml(loadYamlNode(yaml), './');
      expect(config.directoryPath, './');
      expect(config.fileGlobs, allOf(
          const isInstanceOf<List<String>>(),
          contains('web/*.scss')));
      expect(config.sassConfig, isNotNull);
    });

    test('toString()', () {
      var config = new YamlBuilderConfig.fromYaml(loadYamlNode(yaml), './');
      expect(() {
        config.toString();
      }, returnsNormally);
    });
  });
}