/// Bonobo Syntax Tree (BST)

import 'package:symbol_table/symbol_table.dart';

class BstCompilationUnit {
  final String name;
  final List<BstCompilationUnit> imports;
  final Map<String, BstType> types;
  final List<BstFunction> functions;
  const BstCompilationUnit(this.name, this.imports, this.types, this.functions);
}

const BstCompilationUnit core =
    const BstCompilationUnit('core', const [], const {
  'Int': $int,
  'Double': $double,
}, const []);

abstract class Bst {}

class BstType implements Bst {
  final String name;
  final List<BstFields> fields;
  final List<BstMethod> methods;
  const BstType(this.name, this.fields, this.methods);

  bool isType(BstType other) => other.name == name;
}

const BstType $int = const BstType('Int', const [], const []);

const BstType $double = const BstType('Double', const [], const []);

abstract class BstTypeMember implements Bst {
  BstType get parent;
}

class BstFields implements BstTypeMember, Bst {
  final BstType parent;
  final BstType type;
  final String name;
  BstFields(this.parent, this.name, this.type);
}

class BstMethod implements BstTypeMember, Bst {
  final BstType parent;
  final String name;
  final List<BstParameter> parameters;
  final BstType returnType;
  final BstBlock body;
  BstMethod(
      this.parent, this.name, this.parameters, this.returnType, this.body);
}

class BstFunction implements Bst {
  String name;
  List<BstParameter> parameters;
  BstType returnType;
  BstBlock body;

  BstFunction(this.name, this.parameters, this.returnType, this.body);
}

class BstParameter implements Bst {
  String name;
  BstType type;

  BstParameter(this.name, this.type);
}

abstract class BstRhsExpression implements Bst {
  BstType get type;
}

class BstAddition implements BstRhsExpression, Bst {
  final BstRhsExpression left;
  final BstRhsExpression right;
  final BstType type;

  const BstAddition(this.type, this.left, this.right);
}

class BstIntLiteral implements BstRhsExpression, Bst {
  final int value;
  final BstType type;
  const BstIntLiteral(this.value) : type = $int;
}

abstract class BstBlock implements Bst {
  List<BstStatement> get statements;
}

class BstExpressionBlock implements BstBlock, Bst {
  BstRhsExpression expression;

  BstExpressionBlock(this.expression);

  List<BstStatement> get statements => [new BstReturnStatement(expression)];
}

abstract class BstStatement implements Bst {}

class BstReturnStatement implements BstStatement {
  final BstRhsExpression expression;

  const BstReturnStatement(this.expression);
}
