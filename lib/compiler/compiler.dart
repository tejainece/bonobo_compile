import 'package:backend/c_builder/c_builder.dart' as c;
import 'package:backend/bst/bst.dart';

c.CompilationUnit compileUnit(CompilationUnit bst) {
  final ret = new c.CompilationUnit([], [], []);
  for (TypeDecl type in bst.types.values) {
    ret.structs.add(compileTypeDeclaration(type));
  }
  for (Func fn in bst.functions) {
    ret.functions.add(compileFunction(fn));
  }
  return ret;
}

c.Struct compileTypeDeclaration(TypeDecl type) {
  var struct;
  if (type is ClassDecl) {
    struct = new c.Struct(type.name, [], [],
        inherits: [compileExtendType($ReferencedObject)]);
  } else {
    struct =
        new c.Struct(type.name, [], [], inherits: [compileExtendType($Object)]);
  }
  for (Field field in type.fields) {
    final cField = new c.Field(compileVarType(field.type), field.name);
    struct.fields.add(cField);
  }
  if (type is ClassDecl) {
    for (Init method in type.initializers) {
      struct.methods.add(compileClassInitMethod(method));
    }
    // TODO deinitializer
  } else {
    for (Init method in type.initializers) {
      struct.methods.add(compileStructInitMethod(method));
    }
  }
  for (Method method in type.methods) {
    struct.methods.add(compileMethod(method));
  }
  for (SxstOvOp method in type.opMethods) {
    struct.methods.add(compileOpMethod(method));
  }
  return struct;
}

c.Func compileMethod(Method bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  final sts = bst.statements.map(compileStatement).toList();
  return new c.Func(compileVarType(bst.returnType), bst.name, params, sts);
}

c.Func compileStructInitMethod(Init bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  final List<c.Statement> sts = [];
  sts.add(new c.RawStatement(
      new c.RawExpression("${compileVarType(bst.parent)} self")));
  sts.addAll(bst.statements.map(compileStatement));
  sts.add(new c.ReturnStatement(new c.RawExpression('self')));
  return new c.Func(compileVarType(bst.parent),
      "init" + (bst.name.isEmpty ? "" : "_${bst.name}"), params, sts,
      isStatic: true);
}

c.Func compileClassInitMethod(Init bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  final List<c.Statement> sts = [];
  sts.add(new c.RawStatement(new c.RawExpression(
      "${compileVarType(bst.parent)} self(new ${compileExtendType(bst.parent)}())")));
  sts.addAll(bst.statements.map(compileStatement));
  sts.add(new c.ReturnStatement(new c.RawExpression('self')));
  return new c.Func(compileVarType(bst.parent),
      "init" + (bst.name.isEmpty ? "" : "_${bst.name}"), params, sts,
      isStatic: true);
}

String compileOpMethodName(OvOp op) {
  switch (op) {
    case OvOp.add:
      return "operator+";
    case OvOp.sub:
      return "operator-";
    case OvOp.mul:
      return "operator*";
    case OvOp.div:
      return "operator/";
    case OvOp.mod:
      return "operator%";
    default:
      throw new Exception(); // TODO
  }
}

c.Func compileOpMethod(SxstOvOp bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  final sts = bst.statements.map(compileStatement).toList();
  return new c.Func(
      compileVarType(bst.returnType), compileOpMethodName(bst.op), params, sts);
}

c.Func compileFunction(Func bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  final sts = bst.statements.map(compileStatement).toList();
  return new c.Func(compileVarType(bst.returnType), bst.name, params, sts);
}

c.Statement compileStatement(Statement st) {
  if (st is ReturnStatement) return compileReturn(st);
  if (st is AssignStatement) return compileAssign(st);
  if (st is ExpressionStatement)
    return new c.ExpressionStatement(compileExpression(st.exp));
  // TODO
  throw new Exception('Unknown statement!');
}

c.ReturnStatement compileReturn(ReturnStatement st) =>
    compileExpression(st.expression).asReturn();

c.AssignStatement compileAssign(AssignStatement st) {
  return new c.AssignStatement(
      compileExpression(st.lhs), compileExpression(st.rhs));
}

c.Expression compileExpression(Expression exp) {
  if (exp is IntLiteral) {
    return new c.IntLiteral(exp.value);
  }
  if (exp is StringLiteral) {
    return new c.StringLiteral(exp.value);
  }
  if (exp is $Var) {
    return compileVariable(exp);
  }
  if (exp is MemberAccess) {
    return new c.MemberAccess(
        compileExpression(exp.start), compileMemberPart(exp.next));
  }
  if (exp is AddExpression) {
    return new c.BinaryExpression(compileExpression(exp.left),
        c.BinaryOperator.add, compileExpression(exp.right),
        isRef: exp.type is ClassDecl);
  }
  if (exp is MulExpression) {
    return new c.BinaryExpression(compileExpression(exp.left),
        c.BinaryOperator.mul, compileExpression(exp.right),
        isRef: exp.type is ClassDecl);
  }
  if (exp is InitCall) {
    return new c.StaticMethodCall(exp.type.name, exp.methodName,
        exp.args.map(compileExpression).toList());
  }
  if (exp is FuncCall) {
    return new c.FuncCall(exp.name, exp.args.map(compileExpression).toList());
  }
  // TODO
  throw new Exception('Unknown expression ${exp}!');
}

c.MemberPart compileMemberPart(MemberPart part) {
  if (part == null) return null;
  if (part is FieldPart) {
    return new c.FieldPart(part.name, compileMemberPart(part.next));
  }
  if (part is CallPart) {
    return new c.CallPart(part.name, part.args.map(compileExpression).toList(),
        compileMemberPart(part.next));
  }
  // TODO
  throw new Exception('Unknown member part ${part}!');
}

String compileVarType(TypeDecl type) {
  // TODO implement generics
  if (type is! ClassDecl) return type.name;
  return "Reference<${type.name}>";
}

c.TypeName compileExtendType(TypeDecl type) {
  // TODO implement generics
  return new c.TypeName(type.name);
}

c.Expression compileVariable($Var variable) =>
    new c.RawExpression(variable.name);
