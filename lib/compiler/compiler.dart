import 'package:backend/c_builder/c_builder.dart' as c;
import 'package:backend/bst/bst.dart';

c.CompilationUnit compileUnit(CompilationUnit bst) {
  final ret = new c.CompilationUnit([], [], [], []);
  for (TypeDecl type in bst.types.values) {
    ret.structs.add(compileTypeDeclaration(type));
    ret.varDeclStatement.add(compileXaneType(type));
  }
  for (Func fn in bst.functions) {
    ret.functions.add(compileFunction(fn));
  }
  return ret;
}

c.VarDeclStatement compileXaneType(TypeDecl type) {
  return new c.VarDeclStatement(compileVarType($Type), 'xaneType',
      isConstExpr: true, parent: compileUnrefClassType(type));
}

c.Struct compileTypeDeclaration(TypeDecl type) {
  var struct = new c.Struct(type.name, [], []);
  if (type.hasBase) {
    for (InterfaceInherit interface in type.interface) {
      struct.inherits.add(compileExtendType(interface));
    }
    if (type is MixinTypeDecl) {
      for (InterfaceInherit interface in type.mixins) {
        struct.inherits.add(compileExtendType(interface));
      }
    }
  } else {
    if (type is ClassDecl ||
        type is ClassMixinTypeDecl ||
        type is ClassInterfaceDecl) {
      struct = new c.Struct(type.name, [], [],
          inherits: [compileUnrefClassType($ReferencedObject)]);
    } else if (type is StructDecl ||
        type is StructMixinTypeDecl ||
        type is StructInterfaceDecl) {
      struct =
          new c.Struct(type.name, [], [], inherits: [compileVarType($Object)]);
    } else {
      throw new Exception();
    }
  }
  for (Field field in type.fields) {
    final cField = new c.Field(compileVarType(field.type), field.name);
    struct.fields.add(cField);
  }
  if (type is ClassDecl) {
    for (Init method in type.initializers) {
      struct.methods.add(compileClassInitMethod(method));
    }
    if (type.deinitializer != null) {
      struct.deconstructor = new c.Deconstructor(
          '${type.name}', compileBlock(type.deinitializer.body));
    }
  } else if (type is StructDecl) {
    for (Init method in type.initializers) {
      struct.methods.add(compileStructInitMethod(method));
    }
  }
  for (MethodPrototype method in type.methods) {
    if (method is Method) {
      struct.methods.add(compileMethod(method));
    } else {
      struct.methodPrototypes.add(compileMethodPrototype(method));
    }
  }
  for (SxstOvOp method in type.opMethods) {
    struct.methods.add(compileOpMethod(method));
  }
  struct.methods.add(new c.Func(compileVarType($Type), 'runtimeType', [],
      new c.Block([new c.ReturnStatement(new c.RawExpression('xaneType'))])));
  struct.fields.add(new c.Field(compileVarType($Type), 'xaneType',
      isStatic: true,
      isConstExpr: true,
      initialization: new c.FuncCall('Type', [
        new c.StringLiteral("Sample"),
        new c.StringLiteral("Sample"),
        new c.StringLiteral(type.name)
      ])));
  return struct;
}

c.FuncPrototype compileMethodPrototype(MethodPrototype bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  return new c.FuncPrototype(compileVarType(bst.returnType), bst.name, params,
      isVirtual: true, isPureVirtual: true);
}

c.Func compileMethod(Method bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  return new c.Func(
      compileVarType(bst.returnType), bst.name, params, compileBlock(bst.body));
}

c.Func compileStructInitMethod(Init bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  c.Block body;
  if (bst.body.statements.isNotEmpty) {
    body = compileBlock(bst.body,
        preC: [new c.VarDeclStatement(compileVarType(bst.parent), 'self')],
        postC: [new c.ReturnStatement(new c.RawExpression('self'))]);
  } else {
    body = new c.Block([
      new c.ReturnStatement(
          new c.ConstructorCallExpression(compileVarType(bst.parent)))
    ]);
  }
  return new c.Func(compileVarType(bst.parent),
      "init" + (bst.name.isEmpty ? "" : "_${bst.name}"), params, body,
      isStatic: true);
}

c.Func compileClassInitMethod(Init bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  c.Block body;
  if (bst.body.statements.isNotEmpty) {
    body = compileBlock(bst.body, preC: [
      new c.VarDeclStatement(compileVarType(bst.parent), 'self',
          initialize: true,
          args: [
            new c.NewAllocExpression(compileUnrefClassType(bst.parent), [])
          ])
    ], postC: [
      new c.ReturnStatement(new c.RawExpression('self'))
    ]);
  } else {
    body = new c.Block([
      new c.ReturnStatement(new c.ConstructorCallExpression(
          compileVarType(bst.parent),
          [new c.NewAllocExpression(compileUnrefClassType(bst.parent), [])]))
    ]);
  }
  return new c.Func(compileVarType(bst.parent),
      "init" + (bst.name.isEmpty ? "" : "_${bst.name}"), params, body,
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
  return new c.Func(compileVarType(bst.returnType), compileOpMethodName(bst.op),
      params, compileBlock(bst.body));
}

c.Func compileFunction(Func bst) {
  final params = bst.parameters.map((Param param) {
    return new c.Parameter(compileVarType(param.type), param.name);
  }).toList();
  return new c.Func(
      compileVarType(bst.returnType), bst.name, params, compileBlock(bst.body));
}

c.Block compileBlock(Block block,
    {List<c.Statement> preC: const [], List<c.Statement> postC: const []}) {
  var ret = new c.Block([]);
  if (preC.isNotEmpty) ret.statements.addAll(preC);
  for (Statement st in block.statements) {
    if (st is Block) {
      ret.statements.add(compileBlock(st));
    } else {
      ret.statements.add(compileStatement(st));
    }
  }
  if (postC.isNotEmpty) ret.statements.addAll(postC);
  return ret;
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

c.TypeName compileVarType(DeclType type) {
  if(type is GenericPart) {
    // TODO
  }
  // TODO implement generics
  if (type is! ClassDecl) return compileExtendType(type);
  return new c.TypeName('Reference', [compileExtendType(type)]);
}

c.TypeName compileUnrefClassType(ClassInterfaceDecl type) {
  // TODO implement generics
  return new c.TypeName(type.name, []);
}

c.TypeName compileExtendType(InterfaceInherit type) {
  // TODO implement generics
  return new c.TypeName(type.type.name, []);
}

c.Expression compileVariable($Var variable) =>
    new c.RawExpression(variable.name);
