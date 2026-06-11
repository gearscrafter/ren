import '../../config/ren_config.dart';

List<WidgetRule> effectiveRules(RenConfig config) {
  final rules = builtInRules.map((r) {
    final customWeight = config.weights[r.name];
    return customWeight != null
        ? WidgetRule(
            name: r.name,
            reason: r.reason,
            weight: customWeight,
            fix: r.fix,
          )
        : r;
  }).toList();

  for (final custom in config.customRules) {
    rules.add(WidgetRule(
      name: custom.name,
      reason: custom.reason,
      weight: custom.weight,
      fix: custom.fix ?? 'No fix provided — review this pattern manually.',
    ));
  }

  return rules;
}

/// Weight table for costly widget patterns.
const builtInRules = [
  WidgetRule(
    name: 'BackdropFilter',
    reason:
        'Applies image filters to everything beneath it — very GPU intensive.',
    weight: 40,
    fix:
        'Move BackdropFilter outside scrollable areas. Consider a static blurred background.',
  ),
  WidgetRule(
    name: 'ShaderMask',
    reason: 'Runs a shader on every frame — high GPU cost.',
    weight: 35,
    fix:
        'Cache the shaded result as an image. Avoid inside lists or animations.',
  ),
  WidgetRule(
    name: 'Opacity',
    reason: 'Creates an offscreen layer when animated — prefer FadeTransition.',
    weight: 20,
    fix:
        'Use AnimatedOpacity or FadeTransition instead — they avoid the offscreen layer.',
  ),
  WidgetRule(
    name: 'ColorFiltered',
    reason: 'Applies a color filter to its subtree on every paint.',
    weight: 20,
    fix:
        'Apply the color filter to a static image asset instead of a widget subtree.',
  ),
  WidgetRule(
    name: 'ImageFiltered',
    reason: 'Similar cost to BackdropFilter — blurs its own subtree.',
    weight: 35,
    fix: 'Pre-render the blurred image and use it as a static asset.',
  ),
  WidgetRule(
    name: 'ListView',
    reason:
        'Use ListView.builder for long lists — avoids building all children at once.',
    weight: 15,
    fix: 'Replace with ListView.builder to build items on demand.',
  ),
  WidgetRule(
    name: 'GridView',
    reason:
        'Use GridView.builder for long grids — avoids building all children at once.',
    weight: 15,
    fix: 'Replace with GridView.builder to build cells on demand.',
  ),
  WidgetRule(
    name: 'SingleChildScrollView',
    reason:
        'Renders all children eagerly — use ListView.builder if list is dynamic.',
    weight: 20,
    fix: 'Replace with ListView.builder if content is dynamic or long.',
  ),
  WidgetRule(
    name: 'Wrap',
    reason:
        'Lays out all children at once — costly if children are many or heavy.',
    weight: 15,
    fix: 'Consider a lazy alternative if the number of children is large.',
  ),
  WidgetRule(
    name: 'Image.network',
    reason: 'No caching by default — prefer CachedNetworkImage.',
    weight: 25,
    fix:
        'Replace with CachedNetworkImage from the cached_network_image package.',
  ),
  WidgetRule(
    name: 'NetworkImage',
    reason: 'No caching by default — prefer CachedNetworkImageProvider.',
    weight: 25,
    fix: 'Replace with CachedNetworkImageProvider from cached_network_image.',
  ),
  WidgetRule(
    name: 'FadeInImage',
    reason: 'Loads image on every build if not cached — verify cache strategy.',
    weight: 15,
    fix: 'Use CachedNetworkImage with a placeholder instead.',
  ),
  WidgetRule(
    name: 'RepaintBoundary',
    reason:
        'Useful only around frequently-repainting subtrees — misuse adds layer overhead.',
    weight: 5,
    fix:
        'Only use RepaintBoundary around widgets that repaint frequently and independently.',
  ),
  WidgetRule(
    name: 'MediaQuery.of',
    reason:
        'Rebuilds on any MediaQuery change — prefer MediaQuery.sizeOf or MediaQuery.paddingOf.',
    weight: 15,
    fix:
        'Use MediaQuery.sizeOf, MediaQuery.paddingOf, or MediaQuery.viewInsetsOf instead.',
  ),
  WidgetRule(
    name: 'Timer',
    reason:
        'Timer without cancel() may leak — ensure dispose() calls timer.cancel().',
    weight: 20,
    fix: 'Store the Timer reference and call timer.cancel() inside dispose().',
  ),
  WidgetRule(
    name: 'Timer.periodic',
    reason:
        'Periodic timer without cancel() will run forever — always cancel in dispose().',
    weight: 30,
    fix: 'Store the Timer reference and call timer.cancel() inside dispose().',
  ),
  WidgetRule(
    name: 'saveLayer',
    reason:
        'Very expensive GPU operation — creates an offscreen buffer. Avoid unless strictly necessary.',
    weight: 50,
    fix:
        'Avoid saveLayer entirely. Use RepaintBoundary instead to isolate repaints.',
  ),
  WidgetRule(
    name: 'ClipPath',
    reason:
        'Expensive clipping — prefer ClipRRect or BoxDecoration for simple shapes.',
    weight: 25,
    fix:
        'Replace with ClipRRect for rounded corners, or BoxDecoration for simple shapes.',
  ),
  WidgetRule(
    name: 'CustomPaint',
    reason:
        'Custom painting on every frame can be costly — ensure repaint is minimized with shouldRepaint.',
    weight: 20,
    fix: 'Override shouldRepaint to return false when nothing changed.',
  ),
  WidgetRule(
    name: 'StreamController',
    reason: 'Ensure close() is called in dispose() to avoid memory leaks.',
    weight: 25,
    fix: 'Call controller.close() inside dispose().',
  ),
  WidgetRule(
    name: 'StreamSubscription',
    reason: 'Ensure cancel() is called in dispose() to avoid memory leaks.',
    weight: 25,
    fix: 'Call subscription.cancel() inside dispose().',
  ),
  WidgetRule(
    name: 'ClipRRect',
    reason:
        'Cheaper than ClipPath but still triggers rasterization — avoid in animations.',
    weight: 15,
    fix: 'Use BoxDecoration with borderRadius instead when possible.',
  ),
  WidgetRule(
    name: 'Hero',
    reason:
        'Expensive during transitions — avoid with large images or inside lists.',
    weight: 20,
    fix:
        'Avoid Hero with large images. Use flightShuttleBuilder to control the transition.',
  ),
];

class WidgetRule {
  final String name;
  final String reason;
  final int weight;
  final String fix;
  const WidgetRule({
    required this.name,
    required this.reason,
    required this.weight,
    required this.fix,
  });
}
