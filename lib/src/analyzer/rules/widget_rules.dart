import '../../config/ren_config.dart';

List<WidgetRule> effectiveRules(RenConfig config) {
  final rules = builtInRules.map((r) {
    final customWeight = config.weights[r.name];
    return customWeight != null
        ? WidgetRule(name: r.name, reason: r.reason, weight: customWeight)
        : r;
  }).toList();

  for (final custom in config.customRules) {
    rules.add(WidgetRule(
      name: custom.name,
      reason: custom.reason,
      weight: custom.weight,
    ));
  }

  return rules;
}

/// Weight table for costly widget patterns.
const builtInRules  = [
  WidgetRule(
    name: 'BackdropFilter',
    reason:
        'Applies image filters to everything beneath it — very GPU intensive.',
    weight: 40,
  ),
  WidgetRule(
    name: 'ShaderMask',
    reason: 'Runs a shader on every frame — high GPU cost.',
    weight: 35,
  ),
  WidgetRule(
    name: 'Opacity',
    reason: 'Creates an offscreen layer when animated — prefer FadeTransition.',
    weight: 20,
  ),
  WidgetRule(
    name: 'ColorFiltered',
    reason: 'Applies a color filter to its subtree on every paint.',
    weight: 20,
  ),
  WidgetRule(
    name: 'ImageFiltered',
    reason: 'Similar cost to BackdropFilter — blurs its own subtree.',
    weight: 35,
  ),
  WidgetRule(
    name: 'ListView',
    reason:
        'Use ListView.builder for long lists — avoids building all children at once.',
    weight: 15,
  ),
  WidgetRule(
    name: 'GridView',
    reason:
        'Use GridView.builder for long grids — avoids building all children at once.',
    weight: 15,
  ),
  WidgetRule(
    name: 'SingleChildScrollView',
    reason:
        'Renders all children eagerly — use ListView.builder if list is dynamic.',
    weight: 20,
  ),
  WidgetRule(
    name: 'Wrap',
    reason:
        'Lays out all children at once — costly if children are many or heavy.',
    weight: 15,
  ),
  WidgetRule(
    name: 'Image.network',
    reason: 'No caching by default — prefer CachedNetworkImage.',
    weight: 25,
  ),
  WidgetRule(
    name: 'NetworkImage',
    reason: 'No caching by default — prefer CachedNetworkImageProvider.',
    weight: 25,
  ),
  WidgetRule(
    name: 'FadeInImage',
    reason: 'Loads image on every build if not cached — verify cache strategy.',
    weight: 15,
  ),
  WidgetRule(
    name: 'RepaintBoundary',
    reason:
        'Useful only around frequently-repainting subtrees — misuse adds layer overhead.',
    weight: 5,
  ),
  WidgetRule(
    name: 'MediaQuery.of',
    reason:
        'Rebuilds on any MediaQuery change — prefer MediaQuery.sizeOf or MediaQuery.paddingOf.',
    weight: 15,
  ),
  WidgetRule(
    name: 'Timer',
    reason:
        'Timer without cancel() may leak — ensure dispose() calls timer.cancel().',
    weight: 20,
  ),
  WidgetRule(
    name: 'Timer.periodic',
    reason:
        'Periodic timer without cancel() will run forever — always cancel in dispose().',
    weight: 30,
  ),
  WidgetRule(
    name: 'saveLayer',
    reason:
        'Very expensive GPU operation — creates an offscreen buffer. Avoid unless strictly necessary.',
    weight: 50,
  ),
  WidgetRule(
    name: 'ClipPath',
    reason:
        'Expensive clipping — prefer ClipRRect or BoxDecoration for simple shapes.',
    weight: 25,
  ),
  WidgetRule(
    name: 'CustomPaint',
    reason:
        'Custom painting on every frame can be costly — ensure repaint is minimized with shouldRepaint.',
    weight: 20,
  ),
  WidgetRule(
    name: 'StreamController',
    reason: 'Ensure close() is called in dispose() to avoid memory leaks.',
    weight: 25,
  ),
  WidgetRule(
    name: 'StreamSubscription',
    reason: 'Ensure cancel() is called in dispose() to avoid memory leaks.',
    weight: 25,
  ),
  WidgetRule(
    name: 'ClipRRect',
    reason: 'Cheaper than ClipPath but still triggers rasterization — avoid in animations.',
    weight: 15,
  ),
  WidgetRule(
    name: 'Hero',
    reason: 'Expensive during transitions — avoid with large images or inside lists.',
    weight: 20,
  ),
];

class WidgetRule {
  final String name;
  final String reason;
  final int weight;
  const WidgetRule({
    required this.name,
    required this.reason,
    required this.weight,
  });
}

