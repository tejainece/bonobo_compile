part of 'bst.dart';

abstract class TemplateArg implements Sxst {}

class NumTemplateArg implements TemplateArg {
  final int value;
  NumTemplateArg(this.value);
}

class NumTemplateTemplateArg implements TemplateArg {
  final IntGenericPart value;
  NumTemplateTemplateArg(this.value);
}

class ClassTemplateArg implements TemplateArg {
  final ClassInterfaceDecl value;
  ClassTemplateArg(this.value);
}

class ClassTemplateTemplateArg implements TemplateArg {
  final ClassGenericPart value;
  ClassTemplateTemplateArg(this.value);
}

class StructTemplateArg implements TemplateArg {
  final StructInterfaceDecl value;
  StructTemplateArg(this.value);
}

class StructTemplateTemplateArg implements TemplateArg {
  final StructGenericPart value;
  StructTemplateTemplateArg(this.value);
}

class VarType implements Sxst {
  final TypeDecl type;
  final List<TemplateArg> templates;
  VarType(this.type, [List<TemplateArg> templates])
      : templates = templates ?? [];

  bool isSameType(VarType other) {
    // TODO
  }

  bool isAssignableTo(VarType other) {
    // TODO
  }

  VarType getFieldType(String name) {
    // TODO
  }

  VarType getMethodReturnTypeByInvocation(String name, List<Expression> args) {
    // TODO
  }
}
