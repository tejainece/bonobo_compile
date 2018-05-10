part of 'bst.dart';

abstract class Statement implements Sxst {}

class Block implements Statement {
  final List<Statement> statements;
  Block(this.statements);
}

class ReturnStatement implements Statement {
  final Expression expression;

  const ReturnStatement(this.expression);
}

enum AssignOp {
  eq,
}

class AssignStatement implements Statement {
  final Expression lhs;
  final AssignOp op;
  final Expression rhs;

  const AssignStatement(this.lhs, this.op, this.rhs);
}

class ExpressionStatement implements Statement {
  final Expression exp;
  const ExpressionStatement(this.exp);
}
