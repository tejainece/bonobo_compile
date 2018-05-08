/// Bonobo Syntax Tree (BST)

import 'package:symbol_table/symbol_table.dart';

class SxstCompilationUnit {
  final String name;
  final List<SxstCompilationUnit> imports;
  final Map<String, SxstType> types;
  final List<SxstFunction> functions;
  const SxstCompilationUnit(
      this.name, this.imports, this.types, this.functions);
}

const SxstCompilationUnit core =
    const SxstCompilationUnit('core', const [], const {
  'Int': $Int,
  'Double': $Double,
}, const []);

abstract class Sxst {}

class SxstType implements Sxst {
  final String name;
  final List<SxstFields> fields;
  final List<SxstMethod> methods;
  final List<SxstOpMethod> opMethods;
  final List<SxstInit> initializers;

  const SxstType(
      this.name, this.fields, this.methods, this.opMethods, this.initializers);

  bool get isReference => false;

  bool isType(SxstType other) =>
      other.name == name && isReference == other.isReference;
}

/*
class SxstTypeRef implements SxstType {
  final SxstType type;
  const SxstTypeRef(this.type);

  String get name => type.name;
  List<SxstFields> get fields => type.fields;
  List<SxstMethod> get methods => type.methods;

  bool isType(SxstType other) =>
      other.name == name && isReference == other.isReference;

  bool get isReference => true;

  SxstTypeRef get ref => new SxstTypeRef(this); // TODO
}
*/

const SxstType $Int =
    const SxstType('Int', const [], const [], const [], const []);

const SxstType $Double =
    const SxstType('Double', const [], const [], const [], const []);

abstract class SxstTypeMember implements Sxst {
  SxstType get parent;
}

class SxstFields implements SxstTypeMember, Sxst {
  final SxstType parent;
  final SxstType type;
  final String name;
  SxstFields(this.parent, this.name, this.type);
}

class SxstMethod implements SxstTypeMember, Sxst {
  final SxstType parent;
  final String name;
  final List<SxstParameter> parameters;
  final SxstType returnType;
  final List<SxstStatement> statements;
  SxstMethod(this.parent, this.name, this.parameters, this.returnType,
      this.statements);
}

class SxstInit implements SxstTypeMember, Sxst {
  final SxstType parent;
  final String name;
  final List<SxstParameter> parameters;
  final SxstType returnType;
  final List<SxstStatement> statements;
  SxstInit(this.parent, this.name, this.parameters, this.returnType,
      this.statements);
}

enum Operator {
  add,
  sub,
  mul,
  div,
  mod,
}

class SxstOpMethod implements SxstTypeMember, Sxst {
  final SxstType parent;
  final Operator op;
  final List<SxstParameter> parameters;
  final SxstType returnType;
  final List<SxstStatement> statements;
  SxstOpMethod(
      this.parent, this.op, this.parameters, this.returnType, this.statements);
}

class SxstFunction implements Sxst {
  String name;
  List<SxstParameter> parameters;
  SxstType returnType;
  final List<SxstStatement> statements;
  SxstFunction(this.name, this.parameters, this.returnType, this.statements);
}

class SxstParameter implements Sxst {
  String name;
  SxstType type;

  SxstParameter(this.name, this.type);
}

abstract class SxstRhsExpression implements Sxst {
  SxstType get type;
}

abstract class SxstLhsExpression implements Sxst {
  SxstType get type;
}

class SxstAdd implements SxstRhsExpression, Sxst {
  final SxstRhsExpression left;
  final SxstRhsExpression right;
  final SxstType type;

  const SxstAdd(this.type, this.left, this.right);
}

class SxstMul implements SxstRhsExpression, Sxst {
  final SxstRhsExpression left;
  final SxstRhsExpression right;
  final SxstType type;

  const SxstMul(this.type, this.left, this.right);
}

abstract class SxstMemberPart implements Sxst {
  SxstType get type;
  SxstType get nextType;
}

class SxstFieldPart implements SxstMemberPart {
  final SxstType type;
  final String name;
  final SxstMemberPart next;
  SxstFieldPart(this.name, this.type, [this.next]);
  SxstType get nextType => next != null ? next.type : type;
}

class SxstMemberAccess implements SxstRhsExpression, SxstLhsExpression, Sxst {
  final SxstType myType;
  final String name;
  final SxstMemberPart next;
  SxstMemberAccess(this.myType, this.name, this.next);
  SxstType get type => next.type;
}

class SxstIntLiteral implements SxstRhsExpression, Sxst {
  final int value;
  final SxstType type;
  const SxstIntLiteral(this.value) : type = $Int;
}

class SxstVariable implements SxstRhsExpression, SxstLhsExpression, Sxst {
  final String name;
  final SxstType type;
  const SxstVariable(this.name, this.type);
}

abstract class SxstStatement implements Sxst {}

class SxstReturnStatement implements SxstStatement {
  final SxstRhsExpression expression;

  const SxstReturnStatement(this.expression);
}

class SxstAssignStatement implements SxstStatement {
  final SxstLhsExpression lhs;
  // TODO assignOp
  final SxstRhsExpression rhs;

  const SxstAssignStatement(this.lhs, this.rhs);
}
