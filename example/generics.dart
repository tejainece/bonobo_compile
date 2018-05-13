import 'package:backend/backend.dart';

final t_TaskRunner = new StructDecl('TaskRunner');
final t_MyTask = new StructDecl('MyTask');

CompilationUnit unit = new CompilationUnit('Teja')
  ..imports.add(core)
  ..addType(t_TaskRunner)
  ..addType(t_MyTask);

void x() {
  new VarType(t_TaskRunner, [new StructTemplateArg(t_MyTask)]);
}

main() {

  // TODO
}

/*

struct Dog: Animal<Dwell> {

}

 */