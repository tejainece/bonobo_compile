import 'package:backend/c_builder/c_builder.dart' as c;
import 'package:backend/bst/bst.dart';

c.CompilationUnit compileUnit(SxstCompilationUnit bst) {
  final ret = new c.CompilationUnit([], [], []);
  for (SxstType type in bst.types.values) {
    ret.structs.add(compileTypeDeclaration(type));
    ret.functions.addAll(compileMethods(type));
  }
  for (SxstFunction fn in bst.functions) {
    ret.functions.add(compileFunction(fn));
  }
  return ret;
}

c.Struct compileTypeDeclaration(SxstType type) {
  final struct = new c.Struct(compileType(type), []);
  for (SxstFields field in type.fields) {
    final cField = new c.Field(compileType(field.type), field.name);
    struct.fields.add(cField);
  }
  return struct;
}

List<c.Func> compileMethods(SxstType type) {
  final ret = <c.Func>[];
  for (SxstMethod method in type.methods) {
    ret.add(compileMethod(method));
  }
  return ret;
}

c.Func compileMethod(SxstMethod bst) {
  final params = bst.parameters.map((SxstParameter param) {
    return new c.Parameter(compileType(param.type), param.name);
  }).toList();
  params.insert(0, new c.Parameter(bst.parent.name, 'self'));
  final sts = bst.statements.map(compileStatement).toList();
  return new c.Func(compileType(bst.returnType),
      bst.parent.name + '_' + bst.name, params, sts);
}

c.Func compileFunction(SxstFunction bst) {
  final params = bst.parameters.map((SxstParameter param) {
    return new c.Parameter(compileType(param.type), param.name);
  }).toList();
  final sts = bst.statements.map(compileStatement).toList();
  return new c.Func(compileType(bst.returnType), bst.name, params, sts);
}

c.Statement compileStatement(SxstStatement st) {
  if (st is SxstReturnStatement) return compileReturn(st);
  // TODO
  throw new Exception('Unknown statement!');
}

c.Code compileReturn(SxstReturnStatement st) =>
    compileRhsExpression(st.expression).asReturn();

c.Expression compileRhsExpression(SxstRhsExpression exp) {
  if (exp is SxstIntLiteral) {
    return new c.IntLiteral(exp.value);
  }
  if (exp is SxstVariable) {
    return compileVariable(exp);
  }
  if (exp is SxstMemberAccess) {
    return new c.MemberAccess(exp.name, compileMemberPart(exp.next));
  }
  if (exp is SxstAdd) {
    return new c.BinaryExpression(compileRhsExpression(exp.left),
        c.BinaryOperator.add, compileRhsExpression(exp.right));
  }
  if (exp is SxstMul) {
    return new c.BinaryExpression(compileRhsExpression(exp.left),
        c.BinaryOperator.mul, compileRhsExpression(exp.right));
  }
  // TODO
  throw new Exception('Unknown expression!');
}

c.MemberPart compileMemberPart(SxstMemberPart part) {
  if (part is SxstFieldPart) {
    return new c.FieldPart(part.name, compileMemberPart(part.next));
  }
  // TODO
}

String compileType(SxstType type) {
  if (!type.isReference) return type.name;
  return type.name + '&';
}

c.Expression compileVariable(SxstVariable variable) =>
    new c.RawExpression(variable.name);
