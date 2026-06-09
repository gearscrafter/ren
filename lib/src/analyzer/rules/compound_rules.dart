import '../pattern.dart';

const compoundRules = [

  CompoundRule(
    widget: 'Opacity',
    parent: 'AnimatedBuilder',
    reason: 'Opacity inside AnimatedBuilder repaints on every animation tick — use AnimatedOpacity instead.',
    weight: 50,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'Opacity',
    parent: 'ListView',
    reason: 'Opacity inside ListView creates an offscreen layer per visible item — very GPU intensive.',
    weight: 50,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'Opacity',
    parent: 'GridView',
    reason: 'Opacity inside GridView creates an offscreen layer per visible cell — very GPU intensive.',
    weight: 50,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'ListView',
    reason: 'BackdropFilter inside ListView is one of the worst Flutter performance patterns — avoid entirely.',
    weight: 100,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'GridView',
    reason: 'BackdropFilter inside GridView is one of the worst Flutter performance patterns — avoid entirely.',
    weight: 100,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ClipPath',
    parent: 'AnimatedBuilder',
    reason: 'Clipping inside AnimatedBuilder rasterizes on every frame — pre-clip before animating.',
    weight: 62,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ClipRRect',
    parent: 'AnimatedBuilder',
    reason: 'Clipping inside AnimatedBuilder rasterizes on every frame — pre-clip before animating.',
    weight: 37,
    level: PatternLevel.risk,
  ),

  CompoundRule(
    widget: 'NetworkImage',
    parent: 'ListView',
    reason: 'NetworkImage inside ListView loads on every scroll — use CachedNetworkImage.',
    weight: 37,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'NetworkImage',
    parent: 'GridView',
    reason: 'NetworkImage inside GridView loads on every scroll — use CachedNetworkImage.',
    weight: 37,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'Stack',
    reason: 'BackdropFilter inside Stack affects everything rendered beneath it — very GPU intensive.',
    weight: 60,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'Opacity',
    parent: 'PageView',
    reason: 'Opacity inside PageView creates an offscreen layer per page — prefer FadeTransition.',
    weight: 30,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'CustomPaint',
    parent: 'AnimatedBuilder',
    reason: 'CustomPaint inside AnimatedBuilder repaints on every tick — ensure shouldRepaint returns false when unchanged.',
    weight: 30,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'Hero',
    parent: 'ListView',
    reason: 'Hero inside ListView causes expensive transitions — use sparingly.',
    weight: 30,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'Hero',
    parent: 'GridView',
    reason: 'Hero inside GridView causes expensive transitions — use sparingly.',
    weight: 30,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'ShaderMask',
    parent: 'ListView',
    reason: 'ShaderMask triggers saveLayer() on every list item — catastrophic GPU cost.',
    weight: 87,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ShaderMask',
    parent: 'GridView',
    reason: 'ShaderMask triggers saveLayer() on every grid cell — catastrophic GPU cost.',
    weight: 87,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ColorFiltered',
    parent: 'ListView',
    reason: 'ColorFilter triggers saveLayer() on every list item — reduces FPS by up to 50%.',
    weight: 50,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ColorFiltered',
    parent: 'GridView',
    reason: 'ColorFilter triggers saveLayer() on every grid cell — reduces FPS by up to 50%.',
    weight: 50,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ImageFiltered',
    parent: 'ListView',
    reason: 'ImageFiltered inside ListView blurs every item — very GPU intensive.',
    weight: 87,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ImageFiltered',
    parent: 'GridView',
    reason: 'ImageFiltered inside GridView blurs every cell — very GPU intensive.',
    weight: 87,
    level: PatternLevel.risk,
  ),
  CompoundRule(
    widget: 'ShaderMask',
    parent: 'AnimatedBuilder',
    reason: 'ShaderMask triggers saveLayer() on every animation tick — very GPU intensive.',
    weight: 52,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'ClipPath',
    parent: 'ListView',
    reason: 'ClipPath inside ListView rasterizes on every visible item — prefer ClipRRect.',
    weight: 37,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'ClipPath',
    parent: 'GridView',
    reason: 'ClipPath inside GridView rasterizes on every visible cell — prefer ClipRRect.',
    weight: 37,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'CustomPaint',
    parent: 'ListView',
    reason: 'CustomPaint inside ListView repaints on every scroll — ensure shouldRepaint is optimized.',
    weight: 30,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'CustomPaint',
    parent: 'GridView',
    reason: 'CustomPaint inside GridView repaints on every scroll — ensure shouldRepaint is optimized.',
    weight: 30,
    level: PatternLevel.context,
  ),
  CompoundRule(
    widget: 'BackdropFilter',
    parent: 'PageView',
    reason: 'BackdropFilter inside PageView applies GPU filter on every page — very expensive.',
    weight: 60,
    level: PatternLevel.context,
  ),
];

class CompoundRule {
  final String widget;
  final String parent;
  final String reason;
  final int weight;
  final PatternLevel level;

  const CompoundRule({
    required this.widget,
    required this.parent,
    required this.reason,
    required this.weight,
    required this.level,
  });
}