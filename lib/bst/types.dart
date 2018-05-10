part of 'bst.dart';

abstract class TypeDecl implements Sxst {
  String get name;
  List<TypeDecl> get interface;
  List<Field> get fields;
  List<MethodPrototype> get methods;
  List<OvOpPrototype> get opMethods;
  // TODO static fields
  // TODO static methods
  bool isSameType(TypeDecl other);
  void addField(String name, TypeDecl type);
  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, TypeDecl returnType);
  // TODO opMethod
  $Var mkV(String name); // TODO
  Field fieldByName(String name);
  MethodPrototype methodByInvocation(String name, List<Expression> args);
  bool get hasBase;
}

abstract class TypeDeclMixin implements TypeDecl {
  final List<Field> fields = [];
  final List<MethodPrototype> methods = [];
  final List<OvOpPrototype> opMethods = [];
  void addField(String name, TypeDecl type) {
    fields.add(new Field(this, name, type));
  }

  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, TypeDecl returnType) {
    if (returnType == $Self) returnType = this;
    var meth = new MethodPrototype(this, name, parameters, returnType);
    methods.add(meth);
    return meth;
  }

  // TODO opMethod
  $Var mkV(String name) => new $Var(name, this);
  InitCall mk(String name, List<Expression> args) =>
      new InitCall(name, this, args);
  Field fieldByName(String name) =>
      fields.firstWhere((f) => f.name == name, orElse: () => null);
  MethodPrototype methodByInvocation(String name, List<Expression> args) =>
      methods
          .where((m) => m.name == name)
          .firstWhere((m) => m.isInvokable(args), orElse: () => null);

  @override
  bool get hasBase => interface.isNotEmpty;
}

class StructInterfaceDecl extends Object
    with TypeDeclMixin
    implements TypeDecl {
  final String name;
  final List<StructInterfaceDecl> interface = [];
  StructInterfaceDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is StructInterfaceDecl && other.name == name;
}

class ClassInterfaceDecl extends Object with TypeDeclMixin implements TypeDecl {
  final String name;
  final List<ClassInterfaceDecl> interface = [];
  ClassInterfaceDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is ClassInterfaceDecl && other.name == name;
}

abstract class MixinTypeDecl implements TypeDecl {
  List<MixinTypeDecl> get mixins; // TODO
  InitCall mk(String name, List<Expression> args);
  Method addMethod(String name, List<Param> parameters, TypeDecl returnType);
  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, TypeDecl returnType);
  // TODO opMethod
  Method methodByInvocation(String name, List<Expression> args);
}

abstract class MixinTypeDeclMixin implements MixinTypeDecl {
  final List<Field> fields = [];
  final List<MethodPrototype> methods = [];
  final List<OvOpPrototype> opMethods = [];

  void addField(String name, TypeDecl type) {
    fields.add(new Field(this, name, type));
  }

  Method addMethod(String name, List<Param> parameters, TypeDecl returnType) {
    if (returnType == $Self) returnType = this;
    var meth = new Method(this, name, parameters, returnType, []);
    methods.add(meth);
    return meth;
  }

  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, TypeDecl returnType) {
    if (returnType == $Self) returnType = this;
    var meth = new MethodPrototype(this, name, parameters, returnType);
    methods.add(meth);
    return meth;
  }

  // TODO opMethod
  $Var mkV(String name) => new $Var(name, this);
  InitCall mk(String name, List<Expression> args) =>
      new InitCall(name, this, args);
  Field fieldByName(String name) =>
      fields.firstWhere((f) => f.name == name, orElse: () => null);
  Method methodByInvocation(String name, List<Expression> args) => methods
      .where((m) => m.name == name)
      .firstWhere((m) => m.isInvokable(args), orElse: () => null);
  bool get hasBase => interface.isNotEmpty || mixins.isNotEmpty;
}

class StructMixinTypeDecl extends Object
    with MixinTypeDeclMixin
    implements MixinTypeDecl, StructInterfaceDecl {
  final String name;
  final List<StructInterfaceDecl> interface = [];
  final List<StructMixinTypeDecl> mixins = [];
  StructMixinTypeDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is StructMixinTypeDecl && other.name == name;
}

class ClassMixinTypeDecl extends Object
    with MixinTypeDeclMixin
    implements MixinTypeDecl, ClassInterfaceDecl {
  final String name;
  final List<ClassInterfaceDecl> interface = [];
  final List<ClassMixinTypeDecl> mixins = [];
  ClassMixinTypeDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is ClassMixinTypeDecl && other.name == name;
}

abstract class ConcreteTypeDecl implements TypeDecl {
  List<TypeDecl> get mixins; // TODO
  List<Method> get methods;
  List<SxstOvOp> get opMethods;
  List<Init> get initializers;
  Init addInit(List<Param> parameters, {String name: ""});
  InitCall mk(String name, List<Expression> args);
  Method addMethod(String name, List<Param> parameters, TypeDecl returnType);
  // TODO opMethod
  Method methodByInvocation(String name, List<Expression> args);
}

abstract class ConcreteTypeDeclMixin implements ConcreteTypeDecl {
  final List<Field> fields = [];
  final List<Method> methods = [];
  final List<SxstOvOp> opMethods = [];
  final List<Init> initializers = [];
  Init addInit(List<Param> parameters, {String name: ""}) {
    var init = new Init(this, name, parameters, []);
    initializers.add(init);
    return init;
  }

  void addField(String name, TypeDecl type) {
    fields.add(new Field(this, name, type));
  }

  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, TypeDecl returnType) {
    throw new Exception();
  }

  Method addMethod(String name, List<Param> parameters, TypeDecl returnType) {
    if (returnType == $Self) returnType = this;
    var meth = new Method(this, name, parameters, returnType, []);
    methods.add(meth);
    return meth;
  }

  // TODO opMethod
  $Var mkV(String name) => new $Var(name, this);
  InitCall mk(String name, List<Expression> args) =>
      new InitCall(name, this, args);
  Field fieldByName(String name) =>
      fields.firstWhere((f) => f.name == name, orElse: () => null);
  Method methodByInvocation(String name, List<Expression> args) => methods
      .where((m) => m.name == name)
      .firstWhere((m) => m.isInvokable(args), orElse: () => null);
  bool get hasBase => interface.isNotEmpty || mixins.isNotEmpty;
}

class StructDecl extends Object
    with ConcreteTypeDeclMixin
    implements ConcreteTypeDecl, StructMixinTypeDecl {
  final String name;
  final List<StructInterfaceDecl> interface = [];
  final List<StructMixinTypeDecl> mixins = [];
  StructDecl(this.name);
  bool isSameType(TypeDecl other) => other is StructDecl && other.name == name;
}

class ClassDecl extends Object
    with ConcreteTypeDeclMixin
    implements ConcreteTypeDecl, ClassMixinTypeDecl {
  final String name;
  final List<ClassInterfaceDecl> interface = [];
  final List<ClassMixinTypeDecl> mixins = [];
  // TODO deinitializer
  ClassDecl(this.name);
  bool isSameType(TypeDecl other) => other is StructDecl && other.name == name;
}

abstract class TypeMember implements Sxst {
  TypeDecl get parent;
}

class Field implements TypeMember, Sxst {
  final TypeDecl parent;
  final TypeDecl type;
  final String name;
  Field(this.parent, this.name, this.type);
}

class MethodPrototype implements TypeMember {
  final TypeDecl parent;
  final String name;
  final List<Param> parameters;
  final TypeDecl returnType;
  MethodPrototype(this.parent, this.name, this.parameters, this.returnType);

  bool isInvokable(List<Expression> args) {
    if (args.length != parameters.length) return false;
    for (int i = 0; i < args.length; i++) {
      // TODO consider sub-classes
      if (parameters[i].type.isSameType(args[i].type)) return false;
    }
    return true;
  }

  void addParam(String name, TypeDecl type) {
    parameters.add(new Param(name, type));
  }
}

class Method implements TypeMember, MethodPrototype {
  final TypeDecl parent;
  final String name;
  final List<Param> parameters;
  final TypeDecl returnType;
  final List<Statement> statements;
  Method(this.parent, this.name, this.parameters, this.returnType,
      this.statements);

  bool isInvokable(List<Expression> args) {
    if (args.length != parameters.length) return false;
    for (int i = 0; i < args.length; i++) {
      // TODO consider sub-classes
      if (parameters[i].type.isSameType(args[i].type)) return false;
    }
    return true;
  }

  void addParam(String name, TypeDecl type) {
    parameters.add(new Param(name, type));
  }

  void addStatement(Statement st) {
    statements.add(st);
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
  final TypeDecl returnType;
  OvOpPrototype(this.parent, this.op, this.parameters, this.returnType);
}

class SxstOvOp implements TypeMember, OvOpPrototype {
  final TypeDecl parent;
  final OvOp op;
  final List<Param> parameters;
  final TypeDecl returnType;
  final List<Statement> statements;
  SxstOvOp(
      this.parent, this.op, this.parameters, this.returnType, this.statements);
}

class Init implements TypeMember, Sxst {
  final TypeDecl parent;
  final String name;
  final List<Param> parameters;
  final List<Statement> statements;
  Init(this.parent, this.name, this.parameters, this.statements);

  void addParam(String name, TypeDecl type) {
    parameters.add(new Param(name, type));
  }

  void addStatement(Statement st) {
    statements.add(st);
  }

  void addRetSt(Expression exp) {
    addStatement(new ReturnStatement(exp));
  }

  Init addAssign(Expression lhs, Expression rhs) {
    addStatement(new AssignStatement(lhs, AssignOp.eq, rhs));
    return this;
  }
}
