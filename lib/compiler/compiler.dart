import 'package:c_builder/c_builder.dart' as c;
import 'package:backend/bst/bst.dart';

c.CompilationUnit compileUnit(BstCompilationUnit bst) {
  final ret = new c.CompilationUnit();
  for(BstType type in bst.types.values) {
    ret.body.addAll(compileTypeDeclaration(type));
  }
  for(BstFunction fn in bst.functions) {
    ret.body.add(compileFunction(fn));
  }
  return ret;
}

List<c.Code> compileTypeDeclaration(BstType type) {
  final struct = new c.Struct();
  for(BstFields field in type.fields) {
    final cField = new c.Field(compileType(field.type), field.name, null);
    struct.fields.add(cField);
  }
  final ret = <c.Code>[struct];
  for(BstMethod method in type.methods) {
    ret.add(compileMethod(method));
  }
  return ret;
}

c.Code compileMethod(BstMethod bst) {
  final ret = new c.CFunction(compileMethodSignature(bst));
  final sts = bst.body.statements.map(compileStatement);
  ret.body.addAll(sts);
  return ret;
}

c.FunctionSignature compileMethodSignature(BstMethod bst) {
  final ret = new c.FunctionSignature(compileType(bst.returnType), bst.name);
  ret.parameters.add(new c.Parameter(compileType(bst.parent), 'self'));
  final params = bst.parameters.map((BstParameter param) {
    return new c.Parameter(compileType(param.type), param.name);
  });
  ret.parameters.addAll(params);
  return ret;
}

c.CFunction compileFunction(BstFunction bst) {
  final ret = new c.CFunction(compileFunctionSignature(bst));
  final sts = bst.body.statements.map(compileStatement);
  ret.body.addAll(sts);
  return ret;
}

c.FunctionSignature compileFunctionSignature(BstFunction bst) {
  final ret = new c.FunctionSignature(compileType(bst.returnType), bst.name);
  final params = bst.parameters.map((BstParameter param) {
    return new c.Parameter(compileType(param.type), param.name);
  });
  ret.parameters.addAll(params);
  return ret;
}

c.Code compileStatement(BstStatement st) {
  if(st is BstReturnStatement) return compileReturn(st);
  // TODO
  throw new Exception('Unknown statement!');
}

c.Code compileReturn(BstReturnStatement st) =>
    compileRhsExpression(st.expression).asReturn();

c.Expression compileRhsExpression(BstRhsExpression exp) {
  if (exp is BstIntLiteral) {
    return new c.Expression.value(exp.value);
  }
  if (exp is BstAddition) {
    String name = exp.left.type.name;
    return new c.Expression('bonobo_${name}_op_add').invoke(
        [compileRhsExpression(exp.left), compileRhsExpression(exp.right)]);
  }
  // TODO
  throw new Exception('Unknown expression!');
}

c.CType compileType(BstType type) => new c.CType(type.name);