part of 'bst.dart';

// TODO StructDecl $Self = new StructDecl('Self'); // TODO this is not StructDecl

StructDecl $Object = new StructDecl('Object');

StructDecl $Void = new StructDecl('Void');

StructDecl $Int = new StructDecl('Int');

StructDecl $Double = new StructDecl('Double');

StructDecl $Type = new StructDecl('Type');

ClassDecl $ReferencedObject = new ClassDecl('ReferencedObject');

ClassDecl $String = new ClassDecl('String');

CompilationUnit core = new CompilationUnit('core')
  ..types.addAll({
    'Object': $Object,
    'Int': $Int,
    'Double': $Double,
    'ReferencedObject': $ReferencedObject,
    'String': $String,
  });

void setupCore() {
  $Int
    ..addMethod('sqrt', [], new VarType($Int))
    ..addMethod('toString', [], new VarType($String));
}

InitCall newString(String literal) {
  return $String.mk('fromBytes',
      [new StringLiteral(literal), new IntLiteral(literal.length)]);
}
