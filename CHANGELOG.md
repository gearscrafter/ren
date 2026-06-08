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
