/// Weight table for costly widget patterns.
const widgetRules = [
  _WidgetRule(
    name: 'BackdropFilter',
    reason:
        'Applies image filters to everything beneath it — very GPU intensive.',
    weight: 40,
  ),
  _WidgetRule(
    name: 'ShaderMask',
    reason: 'Runs a shader on every frame — high GPU cost.',
    weight: 35,
  ),
  _WidgetRule(
    name: 'Opacity',
    reason: 'Creates an offscreen layer when animated — prefer FadeTransition.',
    weight: 25,
  ),
  _WidgetRule(
    name: 'ColorFiltered',
    reason: 'Applies a color filter to its subtree on every paint.',
    weight: 20,
  ),
  _WidgetRule(
    name: 'ImageFiltered',
    reason: 'Similar cost to BackdropFilter — blurs its own subtree.',
    weight: 35,
  ),
  _WidgetRule(
    name: 'ListView',
    reason:
        'Use ListView.builder for long lists — avoids building all children at once.',
    weight: 30,
  ),
  _WidgetRule(
    name: 'GridView',
    reason:
        'Use GridView.builder for long grids — avoids building all children at once.',
    weight: 30,
  ),
  _WidgetRule(
    name: 'SingleChildScrollView',
    reason:
        'Renders all children eagerly — use ListView.builder if list is dynamic.',
    weight: 20,
  ),
  _WidgetRule(
    name: 'Wrap',
    reason:
        'Lays out all children at once — costly if children are many or heavy.',
    weight: 15,
  ),
  _WidgetRule(
    name: 'Image.network',
    reason: 'No caching by default — prefer CachedNetworkImage.',
    weight: 25,
  ),
  _WidgetRule(
    name: 'NetworkImage',
    reason: 'No caching by default — prefer CachedNetworkImageProvider.',
    weight: 25,
  ),
  _WidgetRule(
    name: 'FadeInImage',
    reason: 'Loads image on every build if not cached — verify cache strategy.',
    weight: 15,
  ),
  _WidgetRule(
    name: 'RepaintBoundary',
    reason:
        'Useful only around frequently-repainting subtrees — misuse adds layer overhead.',
    weight: 15,
  ),
  _WidgetRule(
    name: 'MediaQuery.of',
    reason:
        'Rebuilds on any MediaQuery change — prefer MediaQuery.sizeOf or MediaQuery.paddingOf.',
    weight: 20,
  ),
  _WidgetRule(
    name: 'Timer',
    reason:
        'Timer without cancel() may leak — ensure dispose() calls timer.cancel().',
    weight: 20,
  ),
  _WidgetRule(
    name: 'Timer.periodic',
    reason:
        'Periodic timer without cancel() will run forever — always cancel in dispose().',
    weight: 30,
  ),
  _WidgetRule(
    name: 'saveLayer',
    reason:
        'Very expensive GPU operation — creates an offscreen buffer. Avoid unless strictly necessary.',
    weight: 45,
  ),
  _WidgetRule(
    name: 'ClipPath',
    reason:
        'Expensive clipping — prefer ClipRRect or BoxDecoration for simple shapes.',
    weight: 25,
  ),
  _WidgetRule(
    name: 'CustomPaint',
    reason:
        'Custom painting on every frame can be costly — ensure repaint is minimized with shouldRepaint.',
    weight: 20,
  ),
  _WidgetRule(
    name: 'StreamController',
    reason: 'Ensure close() is called in dispose() to avoid memory leaks.',
    weight: 25,
  ),
  _WidgetRule(
    name: 'StreamSubscription',
    reason: 'Ensure cancel() is called in dispose() to avoid memory leaks.',
    weight: 25,
  ),
];

class _WidgetRule {
  final String name;
  final String reason;
  final int weight;
  const _WidgetRule({
    required this.name,
    required this.reason,
    required this.weight,
  });
}
