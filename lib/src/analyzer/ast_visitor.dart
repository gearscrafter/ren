import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import '../analyzer/pattern.dart';
import '../analyzer/rules/widget_rules.dart';
import '../analyzer/rules/compound_rules.dart';

class GravityVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<WidgetRule> rules;
  final List<RenPattern> _patterns = [];

  String? _currentMethod;
  int _lambdaDepth = 0;

  final List<String> _widgetStack = [];

  GravityVisitor({required this.filePath, required this.rules});

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
    final typeName = _getTypeName(node.constructorName.type);
    final constructorName = node.constructorName.name?.name;

    if (!_isOptimizedConstructor(constructorName)) {
      _evaluateWithContext(typeName, node.offset);
    }

    _widgetStack.add(typeName);
    super.visitInstanceCreationExpression(node);
    _widgetStack.removeLast();
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

    final widgetName = target != null
        ? (_hasRule('$target.$methodName') ? '$target.$methodName' : target)
        : methodName;

    if (target != null) {
      final fullName = '$target.$methodName';
      if (_hasRule(fullName)) {
        _evaluateWithContext(fullName, node.offset);
      } else if (!_isOptimizedConstructor(methodName)) {
        _evaluateWithContext(target, node.offset);
      }
    } else {
      if (!_isOptimizedConstructor(methodName)) {
        _evaluateWithContext(methodName, node.offset);
      }
    }

    _widgetStack.add(widgetName);
    super.visitMethodInvocation(node);
    _widgetStack.removeLast();
  }

  void _evaluateWithContext(String widgetName, int offset) {
    final compound = compoundRules.firstWhere(
      (r) => r.widget == widgetName && _widgetStack.contains(r.parent),
      orElse: () => _noMatch,
    );

    if (compound != _noMatch) {
      final customRule = rules.firstWhere(
        (r) => r.name == widgetName,
        orElse: () => WidgetRule(name: '', reason: '', weight: -1, fix: ''),
      );

      final effectiveWeight = customRule.weight >= 0
          ? _scaleCompoundWeight(compound, customRule.weight)
          : compound.weight;

      _patterns.add(RenPattern(
        name: widgetName,
        reason: compound.reason,
        weight: effectiveWeight,
        file: filePath,
        line: offset,
        level: compound.level,
        context: compound.parent,
        fix: compound.fix,
      ));
      return;
    }

    _matchRule(widgetName, offset);
  }

  int _scaleCompoundWeight(CompoundRule compound, int customBaseWeight) {
    final originalBase = builtInRules.firstWhere(
      (r) => r.name == compound.widget,
      orElse: () => WidgetRule(name: '', reason: '', weight: 1, fix: ''),
    );

    if (originalBase.weight <= 0) return compound.weight;

    final multiplier = compound.weight / originalBase.weight;
    return (customBaseWeight * multiplier).round();
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
        fix: rule.fix,
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
          fix:
              'Move the setState call to a user interaction callback or lifecycle method like initState.',
        ),
      'initState' => const _SetStateRule(
          name: 'setState in initState',
          reason:
              'setState in initState is redundant — widget has not mounted yet.',
          weight: 35,
          fix:
              'Assign state variables directly without setState — the widget rebuilds on first mount anyway.',
        ),
      'dispose' => const _SetStateRule(
          name: 'setState in dispose',
          reason:
              'Calling setState after dispose causes a crash — the widget is no longer mounted.',
          weight: 60,
          fix:
              'Remove setState from dispose. Clean up resources only — never trigger rebuilds here.',
        ),
      _ => const _SetStateRule(
          name: 'setState misuse',
          reason: 'setState called in an unexpected lifecycle method.',
          weight: 25,
          fix:
              'Review where setState is being called and move it to an appropriate callback.',
        ),
    };
  }

  bool _hasRule(String name) => rules.any((r) => r.name == name);

  void _matchRule(String typeName, int offset) {
    for (final rule in rules) {
      if (typeName == rule.name) {
        _patterns.add(RenPattern(
          name: rule.name,
          reason: rule.reason,
          weight: rule.weight,
          file: filePath,
          line: offset,
          level: PatternLevel.presence,
          fix: rule.fix,
        ));
      }
    }
  }

  bool _isOptimizedConstructor(String? name) {
    const optimized = {'builder', 'separated'};
    return name != null && optimized.contains(name);
  }

  static String _getTypeName(NamedType type) {
    try {
      return (type as dynamic).name.lexeme as String;
    } catch (_) {
      return (type as dynamic).name2.lexeme as String;
    }
  }
}

final _noMatch = CompoundRule(
  widget: '',
  parent: '',
  reason: '',
  weight: 0,
  level: PatternLevel.presence,
  fix: '',
);

class _SetStateRule {
  final String name;
  final String reason;
  final int weight;
  final String fix;
  const _SetStateRule({
    required this.name,
    required this.reason,
    required this.weight,
    required this.fix,
  });
}
