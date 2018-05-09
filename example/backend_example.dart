import 'package:backend/backend.dart';
import 'package:backend/bst/bst.dart';
import 'package:backend/compiler/compiler.dart';

StructDecl composePoint() {
  var x = new $Var('x', $Int);
  var y = new $Var('y', $Int);

  StructDecl point_t = new StructDecl('Point')
    ..addField('x', $Int)
    ..addField('y', $Int)
    ..addMethod('length', [], $Double)
        .addRetSt(((x * x) + (y * y)).call('sqrt'));
  point_t.addMethod('toString', [], $String).addRetSt(newString("(")
      .addOp(x.call('toString'))
      .addOp(newString(", "))
      .addOp(y.call('toString'))
      .addOp(newString(")")));
  point_t
    ..addInit([new Param('x', $Int), new Param('y', $Int)])
        .addAssign(point_t.mkV('self').field('x'), $Int.mkV('x'))
        .addAssign(point_t.mkV('self').field('y'), $Int.mkV('y'));

  point_t.opMethods.add(new SxstOvOp(
      point_t,
      OvOp.add,
      [new Param('other', point_t)],
      point_t,
      [
        new ReturnStatement(new InitCall("", point_t, [
          new AddExpression(
              $Int,
              new $Var('x', $Int),
              new MemberAccess(
                  new $Var('other', point_t), new FieldPart('x', $Int))),
          new AddExpression(
              $Int,
              new $Var('y', $Int),
              new MemberAccess(
                  new $Var('other', point_t), new FieldPart('y', $Int)))
        ])),
      ]));
  return point_t;
}

ClassDecl composeAnimal() {
  var animal_t = new ClassDecl('Animal');
  animal_t.addMethod('eat', [], $Void)
    ..addExpSt(new FuncCall($Void, 'print', [newString("yum yum!")]));
  return animal_t;
}

main() {
  setupCore();
  CompilationUnit unit = new CompilationUnit('point', [core], {}, []);

  unit.addType(composePoint());
  unit.addType(composeAnimal());

  final add_f = new Func(
      'add',
      [new Param('a', $Int), new Param('b', $Int)],
      $Int,
      [
        new ReturnStatement(
            new AddExpression($Int, new $Var('a', $Int), new $Var('b', $Int)))
      ]);
  unit.functions.add(add_f);

  print(compileUnit(unit).toCodeSegment());
}

/*
class Point {
  var x: Int
  var y: Int

  fn length: Int => (x * x + y * y).sqrt.toInt;
}
 */
