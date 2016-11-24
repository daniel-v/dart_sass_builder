import 'dart:io';

void main(List<String> args) {
  var scss = new File(args[0]).readAsStringSync();
  stdout.write('// compiled\n$scss');
  exitCode = args.length > 0 ? 0 : 1;
}