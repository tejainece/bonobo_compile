part 'types.dart';
part 'core.dart';
part 'statement.dart';

class CompilationUnit {
  final String name;
  final List<CompilationUnit> imports = [];
  final Map<String, TypeDecl> types = {};
  final List<Func> functions = [];
  CompilationUnit(this.name);
  void addType(TypeDecl type) {
    // TODO throw if type with name already exists
    types[type.name] = type;
  }
}

abstract class Sxst {}

class Func implements Sxst {
  String name;
  List<Param> parameters;
  TypeDecl returnType;
  final List<Statement> statements;
  Func(this.name, this.parameters, this.returnType, this.statements);
}

class Param implements Sxst {
  String name;
  TypeDecl type;

  Param(this.name, this.type);
}

abstract class Expression implements Sxst {
  TypeDecl get type;

  const Expression();

  Expression operator +(Expression other) {
    return addOp(other);
  }

  Expression addOp(Expression other, {TypeDecl resType}) {
    return new AddExpression(resType ?? type, this, other);
  }

  Expression operator *(Expression other) {
    return mulOp(other);
  }

  Expression mulOp(Expression other, {TypeDecl resType}) {
    return new MulExpression(resType ?? type, this, other);
  }

  MemberAccess field(String name) {
    Field f = type.fieldByName(name);
    if (f == null)
      throw new Exception("Field $name not found in ${type.name}!");
    return new MemberAccess(this, new FieldPart(f.name, f.type));
  }

  MemberAccess call(String name, {List<Expression> args: const []}) {
    Method m = type.methodByInvocation(name, args);
    if (m == null)
      throw new Exception("Method $name not found in ${type.name}!");
    return new MemberAccess(this, new CallPart(name, m.returnType, args));
  }

  /* TODO
  FuncCall invoke(List<Expression> args) {
    new FuncCall(type, name, args);
  }
  */
}

class AddExpression extends Expression {
  final Expression left;
  final Expression right;
  final TypeDecl type;

  const AddExpression(this.type, this.left, this.right);
}

class MulExpression extends Expression {
  final Expression left;
  final Expression right;
  final TypeDecl type;

  const MulExpression(this.type, this.left, this.right);
}

// TODO function call

abstract class MemberPart implements Sxst {
  TypeDecl get type;
  TypeDecl get nextType;

  void field(String name);

  void call(String name, {List<Expression> args: const []});
}

class FieldPart implements MemberPart {
  final TypeDecl type;
  final String name;
  MemberPart next;
  FieldPart(this.name, this.type, [this.next]);
  TypeDecl get nextType => next != null ? next.type : type;
  void field(String name) {
    if (next != null) {
      next.field(name);
      return;
    }
    Field f = type.fieldByName(name);
    if (f == null)
      throw new Exception("Field $name not found in ${type.name}!");
    next = FieldPart(f.name, f.type);
  }

  void call(String name, {List<Expression> args: const []}) {
    if (next != null) {
      next.field(name);
      return;
    }
    Method m = type.methodByInvocation(name, args);
    if (m == null) throw new Exception("Method not found!");
    next = new CallPart(name, m.returnType, args);
  }
}

class CallPart implements MemberPart {
  final TypeDecl type;
  final String name;
  final List<Expression> args;
  MemberPart next;
  CallPart(this.name, this.type, this.args, [this.next]);
  TypeDecl get nextType => next != null ? next.type : type;
  void field(String name) {
    if (next != null) {
      next.field(name);
      return;
    }
    Field f = type.fieldByName(name);
    if (f == null)
      throw new Exception("Field $name not found in ${type.name}!");
    next = FieldPart(f.name, f.type);
  }

  void call(String name, {List<Expression> args: const []}) {
    if (next != null) {
      next.field(name);
      return;
    }
    Method m = type.methodByInvocation(name, args);
    if (m == null) throw new Exception("Method not found!");
    next = new CallPart(name, m.returnType, args);
  }
}

// TODO subscript part

class MemberAccess extends Expression {
  final Expression start;
  final MemberPart next;
  MemberAccess(this.start, this.next);
  TypeDecl get type => next.nextType;
  TypeDecl get myType => start.type;
  MemberAccess field(String name) {
    next.field(name);
    return this;
  }

  MemberAccess call(String name, {List<Expression> args: const []}) {
    next.call(name, args: args);
    return this;
  }
}

class FuncCall extends Expression {
  final TypeDecl type;
  final String name;
  final List<Expression> args;
  FuncCall(this.type, this.name, this.args);
}

class InitCall extends Expression {
  final TypeDecl type;
  final String name;
  final List<Expression> args;
  InitCall(this.name, this.type, this.args);

  String get methodName => name.isEmpty ? "init" : "init_${name}";
}

class IntLiteral extends Expression {
  final int value;
  const IntLiteral(this.value);
  TypeDecl get type => $Int;
}

class StringLiteral extends Expression {
  final String value;
  const StringLiteral(this.value);
  TypeDecl get type => $String;
}

class $Var extends Expression {
  final String name;
  final TypeDecl type;
  const $Var(this.name, this.type);
}
