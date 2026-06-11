import '../pattern.dart';

const compoundRules = [
  CompoundRule(
    widget: 'Opacity',
    parent: 'AnimatedBuilder',
    reason: 'Opacity inside AnimatedBuilder repaints on every animation tick.',
    weight: 50,
    level: PatternLevel.risk,
    fix:
        'Replace Opacity with AnimatedOpacity — it avoids the offscreen layer.',
  ),
  CompoundRule(
    widget: 'Opacity',
    parent: 'ListView',
    reason:
        'Opacity inside ListView creates an offscreen layer per visible item.',
    weight: 50,
    level: PatternLevel.risk,
    fix:
        'Remove Opacity from list items. Use a colored Container or Image with opacity baked in.',
  ),
  CompoundRule(
    widget: 'Opacity',
    parent: 'GridView',
    reason:
        'Opacity inside GridView creates an offscreen layer per visible cell.',
    weight: 50,
    level: PatternLevel.risk,
    fix:
        'Remove Opacity from grid cells. Use a colored Container or Image with opacity baked in.',
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'ListView',
    reason:
        'BackdropFilter inside ListView is one of the worst Flutter performance patterns.',
    weight: 100,
    level: PatternLevel.risk,
    fix:
        'Move BackdropFilter outside the ListView. Apply blur to a static background instead.',
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'GridView',
    reason:
        'BackdropFilter inside GridView is one of the worst Flutter performance patterns.',
    weight: 100,
    level: PatternLevel.risk,
    fix:
        'Move BackdropFilter outside the GridView. Apply blur to a static background instead.',
  ),
  CompoundRule(
    widget: 'ClipPath',
    parent: 'AnimatedBuilder',
    reason: 'Clipping inside AnimatedBuilder rasterizes on every frame.',
    weight: 62,
    level: PatternLevel.risk,
    fix:
        'Pre-clip the widget before animating. Animate a non-clipped property instead.',
  ),
  CompoundRule(
    widget: 'ClipRRect',
    parent: 'AnimatedBuilder',
    reason: 'Clipping inside AnimatedBuilder rasterizes on every frame.',
    weight: 37,
    level: PatternLevel.risk,
    fix:
        'Pre-clip the widget before animating. Use BoxDecoration with borderRadius instead.',
  ),
  CompoundRule(
    widget: 'NetworkImage',
    parent: 'ListView',
    reason: 'NetworkImage inside ListView loads on every scroll without cache.',
    weight: 37,
    level: PatternLevel.context,
    fix: 'Use CachedNetworkImage from the cached_network_image package.',
  ),
  CompoundRule(
    widget: 'NetworkImage',
    parent: 'GridView',
    reason: 'NetworkImage inside GridView loads on every scroll without cache.',
    weight: 37,
    level: PatternLevel.context,
    fix: 'Use CachedNetworkImage from the cached_network_image package.',
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'Stack',
    reason:
        'BackdropFilter inside Stack affects everything rendered beneath it.',
    weight: 60,
    level: PatternLevel.context,
    fix:
        'Apply blur to a pre-rendered image asset instead of using BackdropFilter.',
  ),
  CompoundRule(
    widget: 'Opacity',
    parent: 'PageView',
    reason: 'Opacity inside PageView creates an offscreen layer per page.',
    weight: 30,
    level: PatternLevel.context,
    fix: 'Use FadeTransition instead — it avoids the offscreen layer.',
  ),
  CompoundRule(
    widget: 'CustomPaint',
    parent: 'AnimatedBuilder',
    reason: 'CustomPaint inside AnimatedBuilder repaints on every tick.',
    weight: 30,
    level: PatternLevel.context,
    fix:
        'Override shouldRepaint to return false when the painted content has not changed.',
  ),
  CompoundRule(
    widget: 'Hero',
    parent: 'ListView',
    reason: 'Hero inside ListView causes expensive transitions.',
    weight: 30,
    level: PatternLevel.context,
    fix:
        'Use Hero sparingly in lists. Consider flightShuttleBuilder to optimize the transition.',
  ),
  CompoundRule(
    widget: 'Hero',
    parent: 'GridView',
    reason: 'Hero inside GridView causes expensive transitions.',
    weight: 30,
    level: PatternLevel.context,
    fix:
        'Use Hero sparingly in grids. Consider flightShuttleBuilder to optimize the transition.',
  ),
  CompoundRule(
    widget: 'ShaderMask',
    parent: 'ListView',
    reason:
        'ShaderMask triggers saveLayer() on every list item — catastrophic GPU cost.',
    weight: 87,
    level: PatternLevel.risk,
    fix:
        'Pre-render the shaded image as a static asset. Never use ShaderMask inside a list.',
  ),
  CompoundRule(
    widget: 'ShaderMask',
    parent: 'GridView',
    reason:
        'ShaderMask triggers saveLayer() on every grid cell — catastrophic GPU cost.',
    weight: 87,
    level: PatternLevel.risk,
    fix:
        'Pre-render the shaded image as a static asset. Never use ShaderMask inside a grid.',
  ),
  CompoundRule(
    widget: 'ColorFiltered',
    parent: 'ListView',
    reason:
        'ColorFilter triggers saveLayer() on every list item — reduces FPS by up to 50%.',
    weight: 50,
    level: PatternLevel.risk,
    fix: 'Apply the color filter to a pre-rendered image asset instead.',
  ),
  CompoundRule(
    widget: 'ColorFiltered',
    parent: 'GridView',
    reason:
        'ColorFilter triggers saveLayer() on every grid cell — reduces FPS by up to 50%.',
    weight: 50,
    level: PatternLevel.risk,
    fix: 'Apply the color filter to a pre-rendered image asset instead.',
  ),
  CompoundRule(
    widget: 'ImageFiltered',
    parent: 'ListView',
    reason:
        'ImageFiltered inside ListView blurs every item — very GPU intensive.',
    weight: 87,
    level: PatternLevel.risk,
    fix:
        'Pre-render the blurred image as a static asset. Avoid ImageFiltered inside lists.',
  ),
  CompoundRule(
    widget: 'ImageFiltered',
    parent: 'GridView',
    reason:
        'ImageFiltered inside GridView blurs every cell — very GPU intensive.',
    weight: 87,
    level: PatternLevel.risk,
    fix:
        'Pre-render the blurred image as a static asset. Avoid ImageFiltered inside grids.',
  ),
  CompoundRule(
    widget: 'ShaderMask',
    parent: 'AnimatedBuilder',
    reason: 'ShaderMask triggers saveLayer() on every animation tick.',
    weight: 52,
    level: PatternLevel.context,
    fix:
        'Cache the shaded result. Avoid running ShaderMask on every animation frame.',
  ),
  CompoundRule(
    widget: 'ClipPath',
    parent: 'ListView',
    reason: 'ClipPath inside ListView rasterizes on every visible item.',
    weight: 37,
    level: PatternLevel.context,
    fix:
        'Replace ClipPath with ClipRRect for simple shapes, or use BoxDecoration.',
  ),
  CompoundRule(
    widget: 'ClipPath',
    parent: 'GridView',
    reason: 'ClipPath inside GridView rasterizes on every visible cell.',
    weight: 37,
    level: PatternLevel.context,
    fix:
        'Replace ClipPath with ClipRRect for simple shapes, or use BoxDecoration.',
  ),
  CompoundRule(
    widget: 'CustomPaint',
    parent: 'ListView',
    reason: 'CustomPaint inside ListView repaints on every scroll.',
    weight: 30,
    level: PatternLevel.context,
    fix: 'Override shouldRepaint to return false when content has not changed.',
  ),
  CompoundRule(
    widget: 'CustomPaint',
    parent: 'GridView',
    reason: 'CustomPaint inside GridView repaints on every scroll.',
    weight: 30,
    level: PatternLevel.context,
    fix: 'Override shouldRepaint to return false when content has not changed.',
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'PageView',
    reason: 'BackdropFilter inside PageView applies GPU filter on every page.',
    weight: 60,
    level: PatternLevel.context,
    fix:
        'Apply blur to a static background image instead of using BackdropFilter per page.',
  ),
];

class CompoundRule {
  final String widget;
  final String parent;
  final String reason;
  final int weight;
  final PatternLevel level;
  final String fix;

  const CompoundRule({
    required this.widget,
    required this.parent,
    required this.reason,
    required this.weight,
    required this.level,
    required this.fix,
  });
}
