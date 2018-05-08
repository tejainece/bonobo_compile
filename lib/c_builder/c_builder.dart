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
  final Expression target;
  final List<Expression> arguments;
  final MemberPart next;
  CallPart(this.target, this.arguments, [this.next]);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write('.(');
    sb.write(arguments.map((a) => a.toCodeSegment()).join(', '));
    sb.write(')');
    if (next != null) sb.write(next.toCodeSegment());
    return sb.toString();
  }
}

class MemberAccess extends Expression {
  final String target;
  final MemberPart next;
  MemberAccess(this.target, this.next);

  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(target);
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
  BinaryExpression(this.left, this.op, this.right);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write('(');
    sb.write(left.toCodeSegment());
    sb.write(' ');
    sb.write(op.toCodeSegment());
    sb.write(' ');
    sb.write(right.toCodeSegment());
    sb.write(')');
    return sb.toString();
  }
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

class AssignStatement extends Statement {
  final Expression lhs;
  final Expression rhs;
  AssignStatement(this.lhs, this.rhs);

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(lhs.toCodeSegment());
    sb.write(' = ');  // TODO customize assignment
    sb.write(rhs.toCodeSegment());
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

class Func implements Code {
  final bool isStatic;
  final String type;
  final String name;
  final List<Parameter> parameters;
  final List<Statement> body;
  Func(this.type, this.name, this.parameters, this.body,
      {this.isStatic: false});

  @override
  void toC(CodeBuffer buf) {
    if(isStatic) buf.write('static ');
    buf.write(type);
    buf.write(' ');
    buf.write(name);
    buf.write('(');
    buf.write(parameters.map((p) => p.toCodeSegment()).join(', '));
    buf.write(')');
    buf.writeln(' {');
    buf.indent();
    body.map((s) => s.toCodeSegment()).forEach((s) => buf.writeln(s));
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

class Parameter implements Code {
  String type;
  String name;
  Parameter(this.type, this.name);

  @override
  void toC(CodeBuffer buf) {
    buf.write(toCodeSegment());
  }

  @override
  String toCodeSegment() {
    var sb = new StringBuffer();
    sb.write(type);
    sb.write(' ');
    sb.write(name);
    return sb.toString();
  }
}

class Struct implements Code {
  final String name;
  final List<Field> fields;

  // TODO constructors

  // TODO factory constructors

  final List<Func> methods;

  Struct(this.name, List<Field> fields, List<Func> methods)
      : fields = fields ?? <Field>[],
        methods = methods ?? <Func>[];
  void addField(String type, String name) => fields.add(new Field(type, name));

  @override
  void toC(CodeBuffer buf) {
    buf.writeln('struct $name {');
    buf.indent();
    fields.map((f) => '${f.type} ${f.name};').forEach(buf.writeln);
    methods.forEach((s) => s.toC(buf));
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
  String type;
  String name;
  Field(this.type, this.name);

  @override
  void toC(CodeBuffer buf) {}

  @override
  String toCodeSegment() {}
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
