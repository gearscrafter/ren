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
