import 'package:build/src/asset/id.dart';

AssetId toCompiledSassAsset(AssetId inputId) => inputId.changeExtension('.css');