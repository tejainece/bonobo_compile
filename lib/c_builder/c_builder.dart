import 'package:code_buffer/code_buffer.dart';

abstract class Code {
  String toCodeSegment();

  void toC(CodeBuffer buf);
}

class CompilationUnit implements Code {
  final List<Struct> structs;
  final List<Enum> enums;
  final List<Func> functions;
  CompilationUnit(this.structs, this.enums, this.functions);

  @override
  String toCodeSegment() {
    var buf = new CodeBuffer();
    toC(buf);
    return buf.toString();
  }

  @override
  void toC(CodeBuffer buf) {
    structs.forEach((s) => s.toC(buf));
    enums.forEach((s) => s.toC(buf));
    functions.forEach((s) => s.toC(buf));
  }
}

abstract class Expression implements Code {
  const Expression();

  ReturnStatement asReturn() => new ReturnStatement(this);

  Expression add(Expression other) =>
      new BinaryExpression(this, BinaryOperator.add, other);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }
}

class RawExpression extends Expression {
  final String expression;
  RawExpression(this.expression);

  @override
  String toCodeSegment() => expression;
}

abstract class MemberPart extends Code {
  MemberPart get next;
}

class FieldPart extends MemberPart {
  final String name;
  final MemberPart next;
  FieldPart(this.name, [this.next]);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  @override
  String toCodeSegment() =>
      '.' + name + (next != null ? next.toCodeSegment() : '');
}

class CallPart extends MemberPart {
  final String name;
  final List<Expression> arguments;
  final MemberPart next;
  CallPart(this.name, this.arguments, [this.next]);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write('.');
    sb.write(name);
    sb.write('(');
    sb.write(arguments.map((a) => a.toCodeSegment()).join(', '));
    sb.write(')');
    if (next != null) sb.write(next.toCodeSegment());
    return sb.toString();
  }
}

class MemberAccess extends Expression {
  final Expression target;
  final MemberPart next;
  MemberAccess(this.target, this.next);

  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(target.toCodeSegment());
    sb.write(next.toCodeSegment());
    return sb.toString();
  }
}

class FuncCall extends Expression {
  final String name;
  final List<Expression> arguments;
  FuncCall(this.name, this.arguments);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(name);
    sb.write('(');
    sb.write(arguments.map((a) => a.toCodeSegment()).join(', '));
    sb.write(')');
    return sb.toString();
  }
}

class StaticMethodCall extends Expression {
  final String parent;
  final String name;
  final List<Expression> arguments;
  StaticMethodCall(this.parent, this.name, this.arguments);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(parent);
    sb.write('::');
    sb.write(name);
    sb.write('(');
    sb.write(arguments.map((a) => a.toCodeSegment()).join(', '));
    sb.write(')');
    return sb.toString();
  }
}

class BinaryOperator implements Code {
  final int value;
  final String rep;
  const BinaryOperator(this.value, this.rep);
  static const BinaryOperator add = const BinaryOperator(0, '+');
  static const BinaryOperator sub = const BinaryOperator(1, '-');
  static const BinaryOperator mul = const BinaryOperator(2, '*');
  static const BinaryOperator div = const BinaryOperator(3, '/');

  @override
  String toCodeSegment() => rep;

  @override
  void toC(CodeBuffer buf) {
    buf.write(rep);
  }
}

class BinaryExpression extends Expression {
  final Expression left;
  final BinaryOperator op;
  final Expression right;
  final bool isRef;
  BinaryExpression(this.left, this.op, this.right, {this.isRef: false});

  @override
  String toCodeSegment() {
    if (!isRef) {
      var sb = new StringBuffer();
      sb.write('(');
      sb.write(left.toCodeSegment());
      sb.write(' ');
      sb.write(op.toCodeSegment());
      sb.write(' ');
      sb.write(right.toCodeSegment());
      sb.write(')');
      return sb.toString();
    } else {
      var sb = new StringBuffer();
      sb.write(left.toCodeSegment());
      sb.write('->operator');
      sb.write(op.toCodeSegment());
      sb.write('(');
      sb.write(right.toCodeSegment());
      sb.write(')');
      return sb.toString();
    }
  }
}

class NewAllocExpression extends Expression {
  final TypeName type;
  final List<Expression> args;
  const NewAllocExpression(this.type, this.args);

  @override
  String toCodeSegment() =>
      'new ${type.toCodeSegment()}(${args.map((e) => e.toCodeSegment()).join(', ')})';
}

class ConstructorCallExpression extends Expression {
  final TypeName type;
  final List<Expression> args;
  const ConstructorCallExpression(this.type, [this.args = const []]);

  @override
  String toCodeSegment() =>
      '${type.toCodeSegment()}(${args.map((e) => e.toCodeSegment()).join(', ')})';
}

class IntLiteral extends Expression {
  final int value;
  const IntLiteral(this.value);

  @override
  String toCodeSegment() => value.toString();
}

class DoubleLiteral extends Expression {
  final double value;
  const DoubleLiteral(this.value);

  @override
  String toCodeSegment() => value.toString();
}

class StringLiteral extends Expression {
  final String value;
  const StringLiteral(this.value);

  @override
  String toCodeSegment() => '"$value"';
}

class Block implements Statement {
  final List<Statement> statements;
  Block(this.statements);

  @override
  void toC(CodeBuffer buf) {
    buf.writeln('{');
    buf.indent();
    for(Statement st in statements) {
      st.toC(buf);
      buf.writeln();
    }
    buf.outdent();
    buf.writeln('}');
  }

  @override
  String toCodeSegment() {
    var cb = new CodeBuffer();
    toC(cb);
    return cb.toString();
  }
}

abstract class Statement implements Code {
  const Statement();

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }
}

class ReturnStatement extends Statement {
  final Expression expression;
  ReturnStatement(this.expression);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write('return ');
    sb.write(expression.toCodeSegment());
    sb.write(';');
    return sb.toString();
  }
}

class ExpressionStatement extends Statement {
  final Expression expression;
  ExpressionStatement(this.expression);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(expression.toCodeSegment());
    sb.write(';');
    return sb.toString();
  }
}

class AssignStatement extends Statement {
  final Expression lhs;
  final Expression rhs;
  AssignStatement(this.lhs, this.rhs);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(lhs.toCodeSegment());
    sb.write(' = '); // TODO customize assignment
    sb.write(rhs.toCodeSegment());
    sb.write(';');
    return sb.toString();
  }
}

class VarDeclStatement extends Statement {
  final TypeName type;
  final String name;
  final bool initialize;
  final List<Expression> args;
  VarDeclStatement(this.type, this.name,
      {this.initialize: false, this.args: const []});

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(type.toCodeSegment());
    sb.write(' ');
    sb.write(name);
    if (initialize) {
      sb.write('(');
      sb.write(args.map((e) => e.toCodeSegment()).join(', '));
      sb.write(')');
    }
    sb.write(';');
    return sb.toString();
  }
}

class RawStatement extends Statement {
  final RawExpression expression;
  RawStatement(this.expression);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(expression.toCodeSegment());
    sb.write(';');
    return sb.toString();
  }
}

class FuncPrototype implements Code {
  final bool isVirtual;
  final TypeName returns;
  final String name;
  final List<Parameter> parameters;
  FuncPrototype(this.returns, this.name, this.parameters, {this.isVirtual});

  @override
  void toC(CodeBuffer buf) {
    if (isVirtual) buf.write('virtual ');
    buf.write(returns.toCodeSegment());
    buf.write(' ');
    buf.write(name);
    buf.write('(');
    buf.write(parameters.map((p) => p.toCodeSegment()).join(', '));
    buf.writeln(');');
  }

  @override
  String toCodeSegment() {
    var cb = new CodeBuffer();
    toC(cb);
    return cb.toString();
  }
}

class Deconstructor implements Code {
  final bool isVirtual;
  final String name;
  final Block body;
  Deconstructor(this.name, this.body,
      {this.isVirtual: false});

  @override
  void toC(CodeBuffer buf) {
    buf.write('~');
    buf.write(name);
    buf.write('() ');
    body.toC(buf);
  }

  @override
  String toCodeSegment() {
    var cb = new CodeBuffer();
    toC(cb);
    return cb.toString();
  }
}

class Func implements Code {
  final bool isStatic;
  final TypeName returns;
  final String name;
  final List<Parameter> parameters;
  final Block body;
  Func(this.returns, this.name, this.parameters, this.body,
      {this.isStatic: false});

  @override
  void toC(CodeBuffer buf) {
    if (isStatic) buf.write('static ');
    buf.write(returns.toCodeSegment());
    buf.write(' ');
    buf.write(name);
    buf.write('(');
    buf.write(parameters.map((p) => p.toCodeSegment()).join(', '));
    buf.write(') ');
    body.toC(buf);
  }

  @override
  String toCodeSegment() {
    var cb = new CodeBuffer();
    toC(cb);
    return cb.toString();
  }
}

class Parameter implements Code {
  TypeName type;
  String name;
  Parameter(this.type, this.name);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(type.toCodeSegment());
    sb.write(' ');
    sb.write(name);
    return sb.toString();
  }
}

class Struct implements Code {
  final String name;
  final List<TypeName> inherits;
  final List<Field> fields;
  final List<Func> methods;
  final List<FuncPrototype> methodPrototypes;
  Deconstructor deconstructor;

  Struct(this.name, List<Field> fields, List<Func> methods,
      {List<TypeName> inherits, List<FuncPrototype> methodPrototypes})
      : fields = fields ?? <Field>[],
        methods = methods ?? <Func>[],
        inherits = inherits ?? [],
        methodPrototypes = methodPrototypes ?? [];

  @override
  void toC(CodeBuffer buf) {
    buf.write('struct $name');
    if (inherits.length != 0) {
      buf.write(': ');
      buf.write(inherits.map((i) => i.toCodeSegment()).join(", "));
    }
    buf.writeln(' {');
    buf.indent();
    fields.map((f) => f.toCodeSegment()).forEach(buf.writeln);
    methods.forEach((s) => s.toC(buf));
    methodPrototypes.forEach((s) => s.toC(buf));
    if(deconstructor != null) deconstructor.toC(buf);
    buf.outdent();
    buf.writeln('};');
  }

  @override
  String toCodeSegment() {
    var cb = new CodeBuffer();
    toC(cb);
    return cb.toString();
  }
}

class Field implements Code {
  final bool isStatic;
  final bool isConstExpr;
  final bool isConst;
  final TypeName type;
  final String name;
  final Expression initialization;
  Field(this.type, this.name,
      {this.isStatic: false,
      this.isConstExpr: false,
      this.isConst: false,
      this.initialization});

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    if (isStatic) sb.write('static ');
    if (isConst)
      sb.write('const');
    else if (isConstExpr) sb.write('constexpr ');
    sb.write(type.toCodeSegment());
    sb.write(' ');
    sb.write(name);
    if (initialization != null) {
      sb.write(' = ');
      sb.write(initialization.toCodeSegment());
    }
    sb.write(';');
    return sb.toString();
  }
}

class Enum implements Code {
  final String name;
  final List<EnumValue> fields;
  Enum(this.name, List<EnumValue> fields) : fields = fields ?? [];
  void addField(String type, String name, [String value]) =>
      fields.add(new EnumValue(type, name, value));

  @override
  void toC(CodeBuffer buf) {}

  @override
  String toCodeSegment() {}
}

class EnumValue implements Code {
  String type;
  String name;
  String value;
  EnumValue(this.type, this.name, [this.value]);

  @override
  String toCodeSegment() {}

  @override
  void toC(CodeBuffer buf) {}
}

abstract class TemplateArg implements Code {}

class ClassTemplateArg implements TemplateArg {
  // TODO what about template template parameters?
  String name;
  ClassTemplateArg(this.name);

  @override
  String toCodeSegment() {
    return 'class $name';
  }

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }
}

class IntTemplateArg implements TemplateArg {
  String name;
  IntTemplateArg(this.name);

  @override
  String toCodeSegment() {
    return 'uint64_t $name';
  }

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }
}

class Template implements Code {
  String name;
  List<TemplateArg> args;
  Template(this.name, [this.args = const []]);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(name);
    if (args.length != 0) {
      sb.write('<');
      sb.write(args.map((a) => a.toCodeSegment()).join(', '));
      sb.write('>');
    }
    return sb.toString();
  }

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }
}

class TypeName implements Code {
  final String name;
  final List<TypeName> templateArgs;
  TypeName(this.name, this.templateArgs);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(name);
    if (templateArgs.length != 0) {
      sb.write('<');
      sb.write(templateArgs.map((a) => a.toCodeSegment()).join(', '));
      sb.write('>');
    }
    return sb.toString();
  }

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }
}
