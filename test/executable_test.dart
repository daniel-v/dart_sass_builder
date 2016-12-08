@TestOn("vm")
import 'dart:io';
import 'package:sass_builder/executable.dart';
import 'package:scheduled_test/scheduled_test.dart';
import 'package:scheduled_test/descriptor.dart' as d;
import 'util.dart';


main() {
  useSandbox();
  group('', () {
    test('returns null if config file not found', () {
      final config = getConfigFile(new Directory(sandbox));
      expect(config, isNull);
    });

    test('finds file with configFileName', () {
      final yaml = d.file(configFileName, '').create();
      yaml.then((_) {
        final configFile = getConfigFile(new Directory(sandbox));
        expect(configFile, isNotNull);
      });
    });

    test('throws if config is invalid', () {
      final yaml = d.file(configFileName, '').create();
      yaml.then((_) {
        final configFile = getConfigFile(new Directory(sandbox));
        expect(() {
          readConfig(configFile);
        }, throwsA(const isInstanceOf<UnsupportedError>()));
      });
    });

    test('read valid', () {
      final yamlContents = '''
sass:
  builder: dart
  arguments:
files:
- web/*.scss
''';
      final yaml = d.file(configFileName, yamlContents).create();
      yaml.then((_) {
        var configFile = getConfigFile(new Directory(sandbox));
        expect(() {
          readConfig(configFile);
        }, returnsNormally);
      });
    });
  });
}