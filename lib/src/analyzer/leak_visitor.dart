import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'pattern.dart';

/// Detects resource leaks at the class level.
class LeakVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<RenPattern> _patterns = [];

  LeakVisitor({required this.filePath});

  List<RenPattern> get patterns => List.unmodifiable(_patterns);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final analyzer = _ClassLeakAnalyzer(
      filePath: filePath,
      className: _getClassName(node),
    );
    analyzer.analyze(node);
    _patterns.addAll(analyzer.patterns);
    super.visitClassDeclaration(node);
  }

  static String _getClassName(ClassDeclaration node) {
    try {
      return (node as dynamic).name.lexeme as String;
    } catch (_) {}
    try {
      return (node as dynamic).name2.lexeme as String;
    } catch (_) {}
    try {
      return (node as dynamic).declaredElement?.name as String? ?? '';
    } catch (_) {
      return '';
    }
  }
}

class _ClassLeakAnalyzer {
  final String filePath;
  final String className;
  final List<RenPattern> patterns = [];

  final Map<String, _Resource> _created = {};
  final Set<String> _disposed = {};

  _ClassLeakAnalyzer({
    required this.filePath,
    required this.className,
  });

  void analyze(ClassDeclaration node) {
    if (!_isStatefulClass(node)) return;

    _scanFields(node);
    _scanMethods(node);
    _scanDispose(node);
    _reportLeaks();
  }

  void _scanFields(ClassDeclaration node) {
    for (final member in _getMembers(node)) {
      if (member is FieldDeclaration) {
        for (final variable in member.fields.variables) {
          final name = _getVariableName(variable);
          final initializer = variable.initializer;
          if (initializer != null) {
            final resourceType = _detectResourceType(initializer.toString());
            if (resourceType != null) {
              _created[name] = _Resource(
                name: name,
                type: resourceType,
                offset: variable.offset,
              );
            }
          }
        }
      }
    }
  }

  void _scanMethods(ClassDeclaration node) {
    for (final member in _getMembers(node)) {
      if (member is MethodDeclaration) {
        final methodName = _getMethodName(member);
        if (methodName == 'initState' || methodName == 'init') {
          _scanMethodBody(member);
        }
      }
    }
  }

  void _scanMethodBody(MethodDeclaration method) {
    final body = method.body;
    if (body is BlockFunctionBody) {
      for (final statement in body.block.statements) {
        _scanStatement(statement);
      }
    }
  }

  void _scanStatement(Statement statement) {
    if (statement is ExpressionStatement) {
      final expr = statement.expression;
      if (expr is AssignmentExpression) {
        final left = expr.leftHandSide.toString();
        final right = expr.rightHandSide.toString();

        final resourceType = _detectResourceType(right);
        if (resourceType != null) {
          _created[left] = _Resource(
            name: left,
            type: resourceType,
            offset: expr.offset,
          );
        }
      }
    }

    if (statement is Block) {
      for (final s in statement.statements) {
        _scanStatement(s);
      }
    }
  }

  void _scanDispose(ClassDeclaration node) {
    for (final member in _getMembers(node)) {
      if (member is MethodDeclaration && _getMethodName(member) == 'dispose') {
        final body = member.body;
        if (body is BlockFunctionBody) {
          final source = body.toSource();
          for (final resourceName in _created.keys) {
            final type = _created[resourceName]!.type;
            final closeMethod = _closeMethodFor(type);

            if (source.contains('$resourceName.$closeMethod') ||
                source.contains(
                    '${resourceName.replaceAll('_', '')}.$closeMethod')) {
              _disposed.add(resourceName);
            }
          }
        }
        break;
      }
    }
  }

  void _reportLeaks() {
    for (final entry in _created.entries) {
      final name = entry.key;
      final resource = entry.value;

      if (!_disposed.contains(name)) {
        final closeMethod = _closeMethodFor(resource.type);
        final isProviderManaged = resource.type == 'ChangeNotifier' ||
            resource.type == 'ValueNotifier';
        patterns.add(RenPattern(
          name: '${resource.type} leak',
          reason:
              '$name (${resource.type}) is created but $closeMethod() is never called in dispose().',
          weight: _weightFor(resource.type),
          file: filePath,
          line: resource.offset,
          level: PatternLevel.risk,
          fix: isProviderManaged
              ? 'Add $name.$closeMethod() inside dispose() — unless managed by Provider/Riverpod which disposes automatically.'
              : 'Add $name.$closeMethod() inside dispose() to prevent memory leaks.',
        ));
      }
    }
  }

  List<ClassMember> _getMembers(ClassDeclaration node) {
    try {
      return (node as dynamic).members as List<ClassMember>;
    } catch (_) {}
    try {
      return (node as dynamic).declaredMembers as List<ClassMember>;
    } catch (_) {}
    try {
      final fragment = (node as dynamic).declaredFragment;
      if (fragment != null) {
        return (fragment as dynamic).members as List<ClassMember>;
      }
    } catch (_) {}
    return [];
  }

  String _getMethodName(MethodDeclaration node) {
    try {
      return (node as dynamic).name.lexeme as String;
    } catch (_) {}
    try {
      return (node as dynamic).name2.lexeme as String;
    } catch (_) {}
    try {
      return (node as dynamic).declaredElement?.name as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  String _getVariableName(VariableDeclaration node) {
    try {
      return (node as dynamic).name.lexeme as String;
    } catch (_) {}
    try {
      return (node as dynamic).name2.lexeme as String;
    } catch (_) {}
    try {
      return (node as dynamic).declaredElement?.name as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  bool _isStatefulClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause?.superclass.toString() ?? '';
    return extendsClause.startsWith('State') ||
        extendsClause.startsWith('State<') ||
        extendsClause.contains('StatefulWidget') ||
        extendsClause.contains('StateMixin');
  }

  String? _detectResourceType(String expression) {
    if (expression.contains('StreamController')) {
      return 'StreamController';
    }
    if (expression.contains('Timer.periodic') ||
        expression.contains('Timer(')) {
      return 'Timer';
    }
    if (expression.contains('.listen(')) {
      return 'StreamSubscription';
    }
    if (expression.contains('AnimationController')) {
      return 'AnimationController';
    }
    if (expression.contains('TextEditingController')) {
      return 'TextEditingController';
    }
    if (expression.contains('ScrollController')) {
      return 'ScrollController';
    }
    if (expression.contains('FocusNode')) {
      return 'FocusNode';
    }
    if (expression.contains('PageController')) {
      return 'PageController';
    }
    if (expression.contains('TabController')) {
      return 'TabController';
    }
    if (expression.contains('ValueNotifier')) {
      return 'ValueNotifier';
    }
    if (expression.contains('ChangeNotifier')) {
      return 'ChangeNotifier';
    }
    return null;
  }

  String _closeMethodFor(String type) {
    return switch (type) {
      'StreamController' => 'close',
      'StreamSubscription' => 'cancel',
      'Timer' => 'cancel',
      'AnimationController' => 'dispose',
      'TextEditingController' => 'dispose',
      'ScrollController' => 'dispose',
      'FocusNode' => 'dispose',
      'PageController' => 'dispose',
      'TabController' => 'dispose',
      'ValueNotifier' => 'dispose',
      'ChangeNotifier' => 'dispose',
      _ => 'dispose',
    };
  }

  int _weightFor(String type) {
    return switch (type) {
      'StreamController' => 40,
      'StreamSubscription' => 35,
      'Timer' => 35,
      'AnimationController' => 30,
      'TextEditingController' => 25,
      'ScrollController' => 25,
      'FocusNode' => 20,
      'PageController' => 25,
      'TabController' => 25,
      'ValueNotifier' => 20,
      'ChangeNotifier' => 20,
      _ => 20,
    };
  }
}

class _Resource {
  final String name;
  final String type;
  final int offset;

  const _Resource({
    required this.name,
    required this.type,
    required this.offset,
  });
}
