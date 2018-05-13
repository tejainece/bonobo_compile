part of 'bst.dart';

class Init implements TypeMember, Sxst {
  final TypeDecl parent;
  final String name;
  final List<Param> parameters;
  final Block body;
  Init(this.parent, this.name, this.parameters, this.body);

  void addParam(String name, VarType type) {
    parameters.add(new Param(name, type));
  }

  void addStatement(Statement st) {
    body.statements.add(st);
  }

  void addRetSt(Expression exp) {
    addStatement(new ReturnStatement(exp));
  }

  Init addAssign(Expression lhs, Expression rhs) {
    addStatement(new AssignStatement(lhs, AssignOp.eq, rhs));
    return this;
  }
}

class Deinit implements TypeMember, Sxst {
  final TypeDecl parent;
  final Block body;
  Deinit(this.parent, this.body);

  void addStatement(Statement st) {
    body.statements.add(st);
  }

  Deinit addAssign(Expression lhs, Expression rhs) {
    addStatement(new AssignStatement(lhs, AssignOp.eq, rhs));
    return this;
  }
}

abstract class TypeMember implements Sxst {
  TypeDecl get parent;
}

class Field implements TypeMember {
  final TypeDecl parent;
  final VarType type;
  final String name;
  Field(this.parent, this.name, this.type);
}

class MethodPrototype implements TypeMember {
  final TypeDecl parent;
  final String name;
  final List<Param> parameters;
  final VarType returnType;
  MethodPrototype(this.parent, this.name, this.parameters, this.returnType);

  bool isInvokable(List<Expression> args) {
    if (args.length != parameters.length) return false;
    for (int i = 0; i < args.length; i++) {
      // TODO consider sub-classes
      if (parameters[i].type.isSameType(args[i].type)) return false;
    }
    return true;
  }

  void addParam(String name, VarType type) {
    parameters.add(new Param(name, type));
  }
}

class Method implements TypeMember, MethodPrototype {
  final TypeDecl parent;
  final String name;
  final List<Param> parameters;
  final VarType returnType;
  final Block body;
  Method(this.parent, this.name, this.parameters, this.returnType, this.body);

  bool isInvokable(List<Expression> args) {
    if (args.length != parameters.length) return false;
    for (int i = 0; i < args.length; i++) {
      // TODO consider sub-classes
      if (parameters[i].type.isSameType(args[i].type)) return false;
    }
    return true;
  }

  void addParam(String name, VarType type) {
    parameters.add(new Param(name, type));
  }

  void addStatement(Statement st) {
    body.statements.add(st);
  }

  void addRetSt(Expression exp) {
    addStatement(new ReturnStatement(exp));
  }

  void addAssign(Expression lhs, Expression rhs) {
    addStatement(new AssignStatement(lhs, AssignOp.eq, rhs));
  }

  void addExpSt(Expression exp) {
    addStatement(new ExpressionStatement(exp));
  }
}

enum OvOp {
  add,
  sub,
  mul,
  div,
  mod,
}

class OvOpPrototype implements TypeMember {
  final TypeDecl parent;
  final OvOp op;
  final List<Param> parameters;
  final VarType returnType;
  OvOpPrototype(this.parent, this.op, this.parameters, this.returnType);
}

class SxstOvOp implements TypeMember, OvOpPrototype {
  final TypeDecl parent;
  final OvOp op;
  final List<Param> parameters;
  final VarType returnType;
  final Block body;
  SxstOvOp(this.parent, this.op, this.parameters, this.returnType, this.body);
}