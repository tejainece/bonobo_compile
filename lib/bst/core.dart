part of 'bst.dart';

StructDecl $Self = new StructDecl('Self');  // TODO this is not StructDecl

StructDecl $Object = new StructDecl('Object');

StructDecl $Void = new StructDecl('Void');

StructDecl $Int = new StructDecl('Int');

StructDecl $Double = new StructDecl('Double');

ClassDecl $ReferencedObject = new ClassDecl('ReferencedObject');

ClassDecl $String = new ClassDecl('String');

CompilationUnit core = new CompilationUnit('core', [], {
  'Object': $Object,
  'Int': $Int,
  'Double': $Double,
  'ReferencedObject': $ReferencedObject,
  'String': $String,
}, []);

void setupCore() {
  $Int..addMethod('sqrt', [], $Self)..addMethod('toString', [], $String);
}

InitCall newString(String literal) {
  return $String.mk('fromBytes',
      [new StringLiteral(literal), new IntLiteral(literal.length)]);
}
