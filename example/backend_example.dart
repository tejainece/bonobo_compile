import 'package:backend/backend.dart';
import 'package:backend/bst/bst.dart';
import 'package:backend/compiler/compiler.dart';
import 'package:code_buffer/code_buffer.dart';

main() {
  SxstCompilationUnit unit = new SxstCompilationUnit('point', [core], {}, []);

  SxstType point_t = new SxstType('Point', [], []);
  point_t.fields.add(new SxstFields(point_t, 'x', $int));
  point_t.fields.add(new SxstFields(point_t, 'y', $int));

  var x = new SxstMemberAccess(point_t, 'self', new SxstFieldPart($int, 'x'));
  var y = new SxstMemberAccess(point_t, 'self', new SxstFieldPart($int, 'y'));

  point_t.methods.add(new SxstMethod(
      point_t,
      'length',
      [],
      $int,
      [
        new SxstReturnStatement(new SxstAdd(
            $int, new SxstMul($int, x, x), new SxstMul($int, y, y))),
        // new SxstMemberAccess($int, 'self', ['x']),
        // new SxstExpressionBlock()
      ]));
  unit.types[point_t.name] = point_t;

  final add_f = new SxstFunction(
      'add',
      [new SxstParameter('a', $int.ref), new SxstParameter('b', $int.ref)],
      $int,
      [
        new SxstReturnStatement(new SxstAdd($int,
            new SxstVariable('a', $int.ref), new SxstVariable('b', $int.ref)))
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
