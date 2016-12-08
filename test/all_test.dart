@TestOn("vm")
import 'dart:io';

import 'dart:mirrors';

import 'package:test/test.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step_impl.dart';
import 'package:build_test/build_test.dart';
import 'package:sass_builder/sass_builder.dart';

const String sass_contents = ' ';

main() async {
  group('Dart Sass', () {
    test('adds phase', () async {
      var graph = new PackageGraph.forThisPackage();
      var group = new PhaseGroup();
      SassBuilder.addPhases(group, graph, ['somefile.scss']);
      expect(group.buildActions.length, 1);
      expect(group.buildActions[0].length, 1);
      BuildAction action = group.buildActions[0][0];
      expect(action.builder, const isInstanceOf<SassBuilder>());
      expect(action.inputSet.globs, allOf(isNotNull, hasLength(1)));
      expect(action.inputSet.globs.map((glob) => glob.pattern).toList(), contains('somefile.scss'));
    });

    test('declares outputs scss files', () {
      var builder = new SassBuilder();
      var declaredAssets = builder.declareOutputs(new AssetId.parse('a|somefile.scss'));
      expect(declaredAssets, allOf(isList, hasLength(1)));
      expect(declaredAssets[0].toString(), 'a|somefile.css');
    });

    test('runs compiler on asset', () async {
      var primaryInput = makeAsset('a|somefile.scss', 'body{ background-color: black; }');
      var reader = new StubAssetReader();
      var writer = new StubAssetWriter();
      var builder = new SassBuilder(new DartSassCompilationStrategy());
      var buildStep = new BuildStepImpl(primaryInput, builder.declareOutputs(primaryInput.id),
          reader, writer, primaryInput.id.package, const Resolvers());
      await builder.build(buildStep);
      expect(buildStep.outputs, hasLength(1));
      expect(buildStep.outputs[0].id.path, 'somefile.css');
    });
  });

  group('Binary compiler', () {
    CompilationStrategy compilationStrategy;
    setUpAll(() {
      var executablePath = _currentFileUri
          .resolve('res/sass_mock.dart')
          .toFilePath(windows: Platform.isWindows);
      compilationStrategy = new BinaryCompilationStrategy(Platform.executable)
        ..arguments = [executablePath];
    });

    test('can use binary compilation', () async {
      var graph = new PackageGraph.forThisPackage();
      var group = new PhaseGroup();
      SassBuilder.addPhases(group, graph, ['somefile.scss'],
          compiler: compilationStrategy);
      BuildAction action = group.buildActions[0][0];
      SassBuilder builder = action.builder;
      expect(builder.compilationStrategy, same(compilationStrategy));
    });

    test('runs sass compiler', () async {
      var primaryAssetId = new AssetId.parse('a|test/res/simple.scss');
      String assetContents = new File(primaryAssetId.path).readAsStringSync();
      Asset primaryInput = new Asset(primaryAssetId, assetContents);
      var reader = new StubAssetReader();
      var writer = new StubAssetWriter();
      var builder = new SassBuilder(compilationStrategy);
      var buildStep = new BuildStepImpl(primaryInput, builder.declareOutputs(primaryInput.id),
          reader, writer, primaryInput.id.package, const Resolvers());
      await builder.build(buildStep);
      expect(buildStep.outputs, hasLength(1));
      expect(buildStep.outputs[0].id.path, endsWith('simple.css'));
      expect(buildStep.outputs[0].stringContents, startsWith('// compiled'));
    });
  });
}

Uri get _currentFileUri =>
    (reflect(main) as ClosureMirror).function.location.sourceUri;