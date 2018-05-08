import 'package:backend/backend.dart';
import 'package:backend/bst/bst.dart';
import 'package:backend/compiler/compiler.dart';

main() {
  SxstCompilationUnit unit = new SxstCompilationUnit('point', [core], {}, []);

  SxstType point_t = new SxstType('Point', [], [], [], []);
  point_t.fields.add(new SxstFields(point_t, 'x', $Int));
  point_t.fields.add(new SxstFields(point_t, 'y', $Int));

  var x = new SxstVariable('x', $Int);
  var y = new SxstVariable('y', $Int);

  point_t.methods.add(new SxstMethod(
      point_t,
      'length',
      [],
      $Int,
      [
        new SxstReturnStatement(new SxstAdd(
            $Int, new SxstMul($Int, x, x), new SxstMul($Int, y, y))),
        // new SxstMemberAccess($int, 'self', ['x']),
        // new SxstExpressionBlock()
      ]));
  point_t.opMethods.add(new SxstOpMethod(
      point_t,
      Operator.add,
      [new SxstParameter('other', point_t)],
      point_t,
      [
        new SxstReturnStatement(new SxstAdd(
            $Int, new SxstMul($Int, x, x), new SxstMul($Int, y, y))),
      ]));
  point_t.initializers.add(new SxstInit(
      point_t,
      "",
      [new SxstParameter('x', $Int), new SxstParameter('y', $Int)],
      point_t,
      [
        new SxstAssignStatement(
            new SxstMemberAccess(point_t, 'self', new SxstFieldPart('x', $Int)),
            new SxstVariable('x', $Int)),
        new SxstAssignStatement(
            new SxstMemberAccess(point_t, 'self', new SxstFieldPart('y', $Int)),
            new SxstVariable('y', $Int)),
      ]));
  unit.types[point_t.name] = point_t;

  final add_f = new SxstFunction(
      'add',
      [new SxstParameter('a', $Int), new SxstParameter('b', $Int)],
      $Int,
      [
        new SxstReturnStatement(new SxstAdd(
            $Int, new SxstVariable('a', $Int), new SxstVariable('b', $Int)))
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
