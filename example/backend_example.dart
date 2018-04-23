import 'package:backend/backend.dart';
import 'package:backend/bst/bst.dart';
import 'package:backend/compiler/compiler.dart';
import 'package:code_buffer/code_buffer.dart';

main() {
  BstCompilationUnit unit = new BstCompilationUnit('point', [core], {}, []);

  BstType point_t = new BstType('Point', [], []);
  point_t.fields.add(new BstFields(point_t, 'x', $int));
  point_t.fields.add(new BstFields(point_t, 'y', $int));
  unit.types[point_t.name] = point_t;

  final add_f = new BstFunction(
      'add',
      [new BstParameter('a', $int), new BstParameter('b', $double)],
      $int,
      new BstExpressionBlock(
          new BstAddition($int, new BstIntLiteral(5), new BstIntLiteral(20))));
  unit.functions.add(add_f);

  final cb = new CodeBuffer();
  compileUnit(unit).generate(cb);
  print(cb);
}
