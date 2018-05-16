part of 'bst.dart';

abstract class TypeDecl implements Sxst {
  String get name;
  List<GenericPart> get generics;
  List<VarType> get interface;
  List<Field> get fields;
  List<MethodPrototype> get methods;
  List<OvOpPrototype> get opMethods;
  // TODO static fields
  // TODO static methods
  bool isSameType(TypeDecl other);
  void addField(String name, VarType type);
  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, VarType returnType);
  // TODO opMethod
  $Var mkV(String name); // TODO
  Field fieldByName(String name);
  MethodPrototype methodByInvocation(String name, List<Expression> args);
  bool get hasBase;
}

abstract class TypeDeclMixin implements TypeDecl {
  final List<GenericPart> generics = [];
  final List<VarType> interface = [];
  final List<Field> fields = [];
  final List<MethodPrototype> methods = [];
  final List<OvOpPrototype> opMethods = [];
  void addField(String name, VarType type) {
    fields.add(new Field(this, name, type));
  }

  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, VarType returnType) {
    var meth = new MethodPrototype(this, name, parameters, returnType);
    methods.add(meth);
    return meth;
  }

  // TODO opMethod
  $Var mkV(String name) => new $Var(name, new VarType(this)); // TODO
  InitCall mk(String name, List<Expression> args) =>
      new InitCall(name, new VarType(this), args); // TODO
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
  StructInterfaceDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is StructInterfaceDecl && other.name == name;
}

class ClassInterfaceDecl extends Object with TypeDeclMixin implements TypeDecl {
  final String name;
  final List<VarType> interface = [];
  ClassInterfaceDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is ClassInterfaceDecl && other.name == name;
}

abstract class MixinTypeDecl implements TypeDecl {
  List<VarType> get mixins;
  InitCall mk(String name, List<Expression> args);
  Method addMethod(String name, List<Param> parameters, VarType returnType);
  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, VarType returnType);
  // TODO opMethod
  Method methodByInvocation(String name, List<Expression> args);
}

abstract class MixinTypeDeclMixin implements MixinTypeDecl {
  final List<GenericPart> generics = [];
  final List<VarType> interface = [];
  final List<VarType> mixins = [];
  final List<Field> fields = [];
  final List<MethodPrototype> methods = [];
  final List<OvOpPrototype> opMethods = [];

  void addField(String name, VarType type) {
    fields.add(new Field(this, name, type));
  }

  Method addMethod(String name, List<Param> parameters, VarType returnType) {
    var meth = new Method(this, name, parameters, returnType, new Block([]));
    methods.add(meth);
    return meth;
  }

  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, VarType returnType) {
    var meth = new MethodPrototype(this, name, parameters, returnType);
    methods.add(meth);
    return meth;
  }

  // TODO opMethod
  $Var mkV(String name) => new $Var(
      name,
      new VarType(
        this, /* TODO templateArgs: generics */
      ));
  InitCall mk(String name, List<Expression> args) => new InitCall(
      name,
      new VarType(
        this, /* TODO templateArgs */
      ),
      args);
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
  StructMixinTypeDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is StructMixinTypeDecl && other.name == name;
}

class ClassMixinTypeDecl extends Object
    with MixinTypeDeclMixin
    implements MixinTypeDecl, ClassInterfaceDecl {
  final String name;
  ClassMixinTypeDecl(this.name);
  bool isSameType(TypeDecl other) =>
      other is ClassMixinTypeDecl && other.name == name;
}

abstract class ConcreteTypeDecl implements TypeDecl {
  List<Method> get methods;
  List<SxstOvOp> get opMethods;
  List<Init> get initializers;
  Init addInit(List<Param> parameters, {String name: ""});
  InitCall mk(String name, List<Expression> args);
  Method addMethod(String name, List<Param> parameters, VarType returnType);
  // TODO opMethod
  Method methodByInvocation(String name, List<Expression> args);
}

abstract class ConcreteTypeDeclMixin implements ConcreteTypeDecl {
  final List<GenericPart> generics = [];
  final List<VarType> interface = [];
  final List<VarType> mixins = [];
  final List<Field> fields = [];
  final List<Method> methods = [];
  final List<SxstOvOp> opMethods = [];
  final List<Init> initializers = [];
  Init addInit(List<Param> parameters, {String name: ""}) {
    var init = new Init(this, name, parameters, new Block([]));
    initializers.add(init);
    return init;
  }

  void addField(String name, VarType type) {
    fields.add(new Field(this, name, type));
  }

  MethodPrototype addMethodPrototype(
      String name, List<Param> parameters, VarType returnType) {
    throw new Exception();
  }

  Method addMethod(String name, List<Param> parameters, VarType returnType) {
    var meth = new Method(this, name, parameters, returnType, new Block([]));
    methods.add(meth);
    return meth;
  }

  // TODO opMethod
  $Var mkV(String name) => new $Var(
      name,
      new VarType(
        this, /* TODO templateArgs */
      ));
  InitCall mk(String name, List<Expression> args) => new InitCall(
      name,
      new VarType(
        this, /* TODO templateArgs */
      ),
      args);
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
  StructDecl(this.name);
  bool isSameType(TypeDecl other) => other is StructDecl && other.name == name;
}

class ClassDecl extends Object
    with ConcreteTypeDeclMixin
    implements ConcreteTypeDecl, ClassMixinTypeDecl {
  final String name;
  Deinit deinitializer;
  ClassDecl(this.name);
  bool isSameType(TypeDecl other) => other is StructDecl && other.name == name;

  Deinit addDeinit() {
    deinitializer = new Deinit(this, new Block([]));
    return deinitializer;
  }
}
