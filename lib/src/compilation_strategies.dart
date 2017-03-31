import 'dart:io';
import 'dart:async';

import 'package:build/build.dart';
import 'package:sass/src/ast/sass.dart';
import 'package:sass/src/visitor/perform.dart';
import 'package:sass/src/visitor/serialize.dart';
import 'package:path/path.dart' as p;
import 'package:package_resolver/package_resolver.dart';

abstract class CompilationStrategy {
  Future<String> compile(AssetId fromAsset, String scss);
}

class DartSassCompilationStrategy implements CompilationStrategy {

  @override
  Future<String> compile(AssetId fromAsset, String scss) async {
    String outputCss = _renderScss(scss, url: p.toUri(fromAsset.path), color: false);
    return outputCss;
  }

  static Future<String> _renderScss(String contents, {Uri url, bool color: false}) async {
    var sassTree = new Stylesheet.parseScss(contents, url: url, color: color);
    print(p.toUri(p.join(p.current, '.packages')));
    var syncPackageResolver = await (await PackageResolver
        .loadConfig(p.toUri(p.join(p.current, '.packages')))).asSync;
    var cssTree = evaluate(sassTree, color: color, packageResolver: syncPackageResolver);
    return toCss(cssTree);
  }
}


/// Strategy to use an external application for SASS compilation
///
/// dart-sass is currently in alpha and it might be necessary to
/// switch to libsass or ruby-sass for compilation.
///
///     var binaryCompiler = new BinaryCompilationStrategy('/path/to/sass');
///     SassBuilder.addPhases(phases, graph, ['web/*.scss'], compiler: binaryCompiler);
///
//class BinaryCompilationStrategy implements CompilationStrategy {
//
//  /// The binary that will be executed to compile SASS files
//  ///
//  /// Can be either a path of the executable or a command.
//  /// Eg: node-sass
//  final String executable;
//
//  /// Extra arguments to invoke the binary with
//  ///
//  /// These are always binary specific, please consulat the
//  /// documentation for the binary you wish to use.
//  List<String> arguments;
//
//  BinaryCompilationStrategy(this.executable, {this.arguments: const []});
//
//  @override
//  Future<Asset> compile(Asset asset) async {
//    var argumentsCopy = new List<String>.from(arguments)
//      ..addAll([asset.id.path]);
//    ProcessResult result = await Process.run(executable, argumentsCopy, stderrEncoding: UTF8);
//    if (result.exitCode != 0) {
//      throw new StateError("Could not compile sass: ${result.stderr}");
//    }
//    return new Asset(toCompiledSassAsset(asset.id), result.stdout);
//  }
//}