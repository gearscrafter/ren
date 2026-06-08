import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import '../analyzer/pattern.dart';
import '../analyzer/rules/widget_rules.dart';

class GravityVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<RenPattern> _patterns = [];

  String? _currentMethod;

  int _lambdaDepth = 0;

  GravityVisitor({required this.filePath});

  List<RenPattern> get patterns => List.unmodifiable(_patterns);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final previousMethod = _currentMethod;
    final previousLambdaDepth = _lambdaDepth;
    _currentMethod = node.name.lexeme;
    _lambdaDepth = 0;
    super.visitMethodDeclaration(node);
    _currentMethod = previousMethod;
    _lambdaDepth = previousLambdaDepth;
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    _lambdaDepth++;
    super.visitFunctionExpression(node);
    _lambdaDepth--;
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;
    final constructorName = node.constructorName.name?.name;

    if (!_isOptimizedConstructor(constructorName)) {
      _matchRule(typeName, node.offset);
    }

    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;
    final target = node.target?.toString();

    if (methodName == 'setState') {
      if (target == null) {
        _checkSetStateContext(node);
      }
      super.visitMethodInvocation(node);
      return;
    }

    const methodOnlyRules = {'saveLayer'};
    if (methodOnlyRules.contains(methodName)) {
      _matchRule(methodName, node.offset);
      super.visitMethodInvocation(node);
      return;
    }

    if (target != null) {
      final fullName = '$target.$methodName';
      if (_hasRule(fullName)) {
        _matchRule(fullName, node.offset);
      } else if (!_isOptimizedConstructor(methodName)) {
        _matchRule(target, node.offset);
      }
    } else {
      if (!_isOptimizedConstructor(methodName)) {
        _matchRule(methodName, node.offset);
      }
    }

    super.visitMethodInvocation(node);
  }

  void _checkSetStateContext(MethodInvocation node) {
    const dangerousMethods = {'build', 'initState', 'dispose'};

    if (_lambdaDepth > 0) return;

    if (_currentMethod != null && dangerousMethods.contains(_currentMethod)) {
      final rule = _setStateRule(_currentMethod!);
      _patterns.add(RenPattern(
        name: rule.name,
        reason: rule.reason,
        weight: rule.weight,
        file: filePath,
        line: node.offset,
      ));
    }
  }

  _SetStateRule _setStateRule(String method) {
    return switch (method) {
      'build' => const _SetStateRule(
          name: 'setState in build',
          reason:
              'Calling setState inside build triggers infinite rebuild loop.',
          weight: 50,
        ),
      'initState' => const _SetStateRule(
          name: 'setState in initState',
          reason:
              'setState in initState is redundant — widget has not mounted yet, use direct assignment instead.',
          weight: 35,
        ),
      'dispose' => const _SetStateRule(
          name: 'setState in dispose',
          reason:
              'Calling setState after dispose causes a crash — the widget is no longer mounted.',
          weight: 60,
        ),
      _ => const _SetStateRule(
          name: 'setState misuse',
          reason: 'setState called in an unexpected lifecycle method.',
          weight: 25,
        ),
    };
  }

  bool _hasRule(String name) => widgetRules.any((r) => r.name == name);

  void _matchRule(String typeName, int offset) {
    for (final rule in widgetRules) {
      if (typeName == rule.name) {
        _patterns.add(RenPattern(
          name: rule.name,
          reason: rule.reason,
          weight: rule.weight,
          file: filePath,
          line: offset,
        ));
      }
    }
  }

  bool _isOptimizedConstructor(String? name) {
    const optimized = {'builder', 'separated'};
    return name != null && optimized.contains(name);
  }
}

class _SetStateRule {
  final String name;
  final String reason;
  final int weight;
  const _SetStateRule({
    required this.name,
    required this.reason,
    required this.weight,
  });
}
