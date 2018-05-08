import 'package:backend/c_builder/c_builder.dart' as c;
import 'package:backend/bst/bst.dart';

c.CompilationUnit compileUnit(SxstCompilationUnit bst) {
  final ret = new c.CompilationUnit([], [], []);
  for (SxstType type in bst.types.values) {
    ret.structs.add(compileTypeDeclaration(type));
  }
  for (SxstFunction fn in bst.functions) {
    ret.functions.add(compileFunction(fn));
  }
  return ret;
}

c.Struct compileTypeDeclaration(SxstType type) {
  final struct = new c.Struct(compileType(type), [], []);
  for (SxstFields field in type.fields) {
    final cField = new c.Field(compileType(field.type), field.name);
    struct.fields.add(cField);
  }
  for (SxstInit method in type.initializers) {
    struct.methods.add(compileInitMethod(method));
  }
  for (SxstMethod method in type.methods) {
    struct.methods.add(compileMethod(method));
  }
  for (SxstOpMethod method in type.opMethods) {
    struct.methods.add(compileOpMethod(method));
  }
  return struct;
}

c.Func compileMethod(SxstMethod bst) {
  final params = bst.parameters.map((SxstParameter param) {
    return new c.Parameter(compileType(param.type), param.name);
  }).toList();
  final sts = bst.statements.map(compileStatement).toList();
  return new c.Func(compileType(bst.returnType), bst.name, params, sts);
}

c.Func compileInitMethod(SxstInit bst) {
  final params = bst.parameters.map((SxstParameter param) {
    return new c.Parameter(compileType(param.type), param.name);
  }).toList();
  final List<c.Statement> sts = [];
  sts.add(new c.RawStatement(
      new c.RawExpression("${compileType(bst.parent)} self")));
  sts.addAll(bst.statements.map(compileStatement));
  sts.add(new c.ReturnStatement(new c.RawExpression('self')));
  return new c.Func(compileType(bst.returnType),
      "init" + (bst.name.isEmpty ? "" : "_${bst.name}"), params, sts,
      isStatic: true);
}

String compileOpMethodName(Operator op) {
  switch (op) {
    case Operator.add:
      return "xane_add";
    case Operator.sub:
      return "xane_sub";
    case Operator.mul:
      return "xane_mul";
    case Operator.div:
      return "xane_div";
    case Operator.mod:
      return "xane_mod";
    default:
      throw new Exception(); // TODO
  }
}

c.Func compileOpMethod(SxstOpMethod bst) {
  final params = bst.parameters.map((SxstParameter param) {
    return new c.Parameter(compileType(param.type), param.name);
  }).toList();
  final sts = bst.statements.map(compileStatement).toList();
  return new c.Func(
      compileType(bst.returnType), compileOpMethodName(bst.op), params, sts);
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
  if (st is SxstAssignStatement) return compileAssign(st);
  // TODO
  throw new Exception('Unknown statement!');
}

c.ReturnStatement compileReturn(SxstReturnStatement st) =>
    compileRhsExpression(st.expression).asReturn();

c.AssignStatement compileAssign(SxstAssignStatement st) {
  return new c.AssignStatement(
      compileLhsExpression(st.lhs), compileRhsExpression(st.rhs));
}

c.Expression compileLhsExpression(SxstLhsExpression exp) {
  if (exp is SxstVariable) {
    return compileVariable(exp);
  }
  if (exp is SxstMemberAccess) {
    return new c.MemberAccess(exp.name, compileMemberPart(exp.next));
  }
  throw new Exception("Unknown LHS expression");
}

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
