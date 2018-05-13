part of 'bst.dart';

abstract class GenericPart implements Sxst {}

class StructGenericPart implements GenericPart {
  final String name;
  final VarType interface;
  StructGenericPart(this.name, [VarType interface])
      : interface = interface ?? $Object; // TODO
  /* TODO
  List<Field> get fields => interface.fields;
  List<MethodPrototype> get methods => interface.methods;
  List<OvOpPrototype> get opMethods => interface.opMethods;
  bool isSameType(TypeDecl other) => interface.isSameType(other);
  Field fieldByName(String name) => interface.fieldByName(name);
  MethodPrototype methodByInvocation(String name, List<Expression> args) =>
      interface.methodByInvocation(name, args);
      */
}

class ClassGenericPart implements GenericPart {
  final String name;
  final VarType interface;
  ClassGenericPart(this.name, [VarType interface])
      : interface = interface ?? $ReferencedObject; // TODO
  /* TODO
  List<Field> get fields => interface.fields;
  List<MethodPrototype> get methods => interface.methods;
  List<OvOpPrototype> get opMethods => interface.opMethods;
  bool isSameType(TypeDecl other) => interface.isSameType(other);
  Field fieldByName(String name) => interface.fieldByName(name);
  MethodPrototype methodByInvocation(String name, List<Expression> args) =>
      interface.methodByInvocation(name, args);
      */
}

class IntGenericPart implements GenericPart {
  final String name;
  StructDecl get interface => $Int;
  IntGenericPart(this.name);
  /* TODO
  List<Field> get fields => interface.fields;
  List<MethodPrototype> get methods => interface.methods;
  List<OvOpPrototype> get opMethods => interface.opMethods;
  bool isSameType(TypeDecl other) => interface.isSameType(other);
  Field fieldByName(String name) => interface.fieldByName(name);
  MethodPrototype methodByInvocation(String name, List<Expression> args) =>
      interface.methodByInvocation(name, args);
      */
}

/*

interface Dwell: Object {
  let name: String
}

struct Kennel: Dwell {
  name: String = "Kennel"
}

struct Cattery: Dwell {
  name: String = "Cattery"
}

interface Animal<D: Dwell>: Object {
  dwell: D
  fn eat()
}

struct Dog: Animal<Kennel> {
  dwell: Kennel
  init(this.dwell)
  fn eat() => print("yum yum!")
  fn bark() => print("bow bow!")
}

struct Cat: Animal<Cattery> {
  dwell: Cattery
  init(this.dwell)
  fn eat() => print("yum yum!")
  fn meow() => print("meow meow!")
}

struct Owner<D: Dwell, T: Animal<D>> {
  animal: T
}

struct Header<N: #>: Object {
  bytes: Int8<N>
  fn something() {
    var v: Animal<Dwell>
  }
}

 */