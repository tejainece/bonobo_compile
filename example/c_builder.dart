import 'package:backend/c_builder/c_builder.dart';

class A {
  int a;
}

A getA() => A();

main() {
  final unit = new CompilationUnit([], [], [
    new Func('i8', 'add', [
      new Parameter('i8', 'a'),
      new Parameter('i8', 'b')
    ], [
      new ReturnStatement(new IntLiteral(5).add(new IntLiteral(5))),
    ]),
  ]);
  print(unit.toCodeSegment());
}
