## 0.3.1

### Fixed
- `ConfigLoader` now normalizes `projectPath` via `p.normalize(p.absolute(...))`.

## 0.3.0

### Added
- `AnalysisContextCollection` support — ren now uses full semantic analysis
  instead of `parseString`, resolving imports, re-exports, and type aliases
  correctly. Falls back to `parseString` automatically if the context cannot
  be built (e.g. `pub get` not run).

## 0.2.3

### Fixed
- Feature scanner now includes `.dart` files at the root of the specified
  feature folder as a named feature — previously only sub-directories were
  scanned, causing files at the root level to be silently skipped.

## 0.2.2

### Fixed
- `LeakVisitor` — added curly braces to all single-line `if` statements in
  `_detectResourceType` to satisfy `curly_braces_in_flow_control_structures`
  lint rule.

## 0.2.1

### Fixed
- `LeakVisitor` compatibility with `analyzer >=7.1.0` — added fallback helpers
  for `ClassDeclaration.name`, `ClassDeclaration.members`,
  `MethodDeclaration.name`, and `VariableDeclaration.name` to support
  lower bound versions without breaking newer ones.
- `ChangeNotifier` and `ValueNotifier` leak fix message now clarifies that
  Provider/Riverpod disposes them automatically.

## 0.2.0

### Added
- `ren --init` — scans project structure and generates `ren.yaml` automatically.
- Auto-discovery — detects feature root without `--features` flag, supports non-conventional structures (`lib/ui/screens`, `lib/presentation/pages`, etc.).
- `ren.yaml` support — project-level configuration:
  - `features`, `fail_on`, `ignore`, `weights`, `custom_rules`.
  - CLI flags always take priority over `ren.yaml`.
- Actionable fix per pattern — every detected pattern includes a `->` suggestion.
- Resource leak detection (`LeakVisitor`) — verifies that `StreamController`, `StreamSubscription`, `Timer`, `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode`, `PageController`, `TabController`, `ValueNotifier`, `ChangeNotifier` are closed in `dispose()`.
- Score normalization by pattern level — presence, context, and risk patterns use separate weight ceilings.
- Output improvements — separators between features, pattern level icons (⚪ 🟡 🔴), gravity legend at the top of the report.
- JSON output now includes `level`, `context`, `reason`, and `fix` per pattern.
- Windows hint — suggests `Remove-Item Alias:ren -Force` on PowerShell.

## 0.1.0

### Added
- Compound rule detection — 20+ widget combinations with elevated weights:
  - Level 3 (critical × 2.5) — `BackdropFilter`/`ShaderMask`/`ImageFiltered`/`ColorFiltered` inside `ListView`/`GridView`, `Opacity`/`ClipPath`/`ClipRRect` inside `AnimatedBuilder`, `Opacity` inside `ListView`/`GridView`.
  - Level 2 (high × 1.5) — `BackdropFilter` inside `Stack`/`PageView`, `NetworkImage` inside `ListView`/`GridView`, `CustomPaint`/`ClipPath` inside `AnimatedBuilder`/`ListView`/`GridView`, `Hero` inside `ListView`/`GridView`, `ShaderMask` inside `AnimatedBuilder`.
- Top contributors breakdown per feature — shows which patterns contribute most to the gravity score.
- `[inside ParentWidget]` context tag on compound patterns.
- `renw` executable — fallback for Windows PowerShell where `ren` conflicts with `Rename-Item`.
- New patterns — `ClipRRect`, `Hero`.
- `lambda-depth` tracking to avoid false positives on `setState` inside callbacks.

### Fixed
- `setState` false positives on callbacks with target (e.g. `state.setState`, `logic.setState`).
- `GridView.count` and other non-lazy named constructors now correctly flagged.
- `Image.network` detection via full name matching in `visitMethodInvocation`.


## 0.0.1

- Feature detection by folder convention (`lib/features/`, `lib/modules/`).
- `--features` flag for custom feature roots (e.g. `lib/ui/screens`).
- `--exclude` flag — comma-separated list of paths to exclude from analysis (e.g. `lib/generated,lib/_tools`).
- Simplified CLI — `ren` runs analysis directly without subcommand.
- AST-based pattern detection across six categories:
  - GPU-costly widgets — `BackdropFilter`, `ShaderMask`, `Opacity`, `ColorFiltered`, `ImageFiltered`, `saveLayer`, `ClipPath`, `CustomPaint`.
  - Unoptimized lists — `ListView`, `GridView`, `SingleChildScrollView`, `Wrap`.
  - Uncached images — `Image.network`, `NetworkImage`, `FadeInImage`.
  - Rebuild patterns — `RepaintBoundary`, `MediaQuery.of`.
  - Memory leaks — `Timer`, `Timer.periodic`, `StreamController`, `StreamSubscription`.
  - Lifecycle misuse — `setState in build`, `setState in initState`, `setState in dispose`.
- Gravity score (0–100) per feature mapped to `LOW / MEDIUM / HIGH / CRITICAL`.
- ANSI console output with gravity bar and per-pattern hints.
- JSON output (`--format json`) for CI/CD pipelines.
- `--fail-on` flag — exits with code 1 if any feature reaches the specified level.
