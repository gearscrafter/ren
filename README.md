# REN

> Flutter Feature Gravity Analyzer

**REN** measures the performance weight of each feature in your Flutter project
by detecting costly AST patterns — reporting a gravity score per feature,
without running the app, without Firebase, without manual instrumentation.

---

## Installation

```bash
dart pub global activate ren
```

## Usage

```bash
# Analyze the current project
ren

# Analyze a specific path
ren --project ./my_app

# Custom feature root
ren --project ./my_app --features lib/ui/screens

# Exclude generated or internal paths
ren --project ./my_app --exclude lib/generated,lib/_tools

# JSON output for CI/CD
ren --format json > ren-report.json

# Fail pipeline if any feature reaches HIGH or above
ren --fail-on high
```

## How it works

ren scans your project's Dart source files using the `analyzer` package,
visits the AST of each file, and detects patterns known to cause performance
issues in Flutter apps. Each pattern carries a weight, and the total weight
per feature is normalized to a 0–100 gravity score.

If no feature root is found (`lib/features/`, `lib/modules/`), ren falls back
to treating `lib/` as a single feature — so it always produces output regardless
of your project structure.

## Detected patterns

| Category | Pattern | Weight |
|---|---|---|
| GPU | `BackdropFilter` | 40 |
| GPU | `saveLayer` | 45 |
| GPU | `ShaderMask` | 35 |
| GPU | `ImageFiltered` | 35 |
| GPU | `ClipPath` | 25 |
| GPU | `Opacity` | 25 |
| GPU | `CustomPaint` | 20 |
| GPU | `ColorFiltered` | 20 |
| Lists | `ListView` | 30 |
| Lists | `GridView` | 30 |
| Lists | `SingleChildScrollView` | 20 |
| Lists | `Wrap` | 15 |
| Images | `Image.network` | 25 |
| Images | `NetworkImage` | 25 |
| Images | `FadeInImage` | 15 |
| Rebuilds | `MediaQuery.of` | 20 |
| Rebuilds | `RepaintBoundary` | 15 |
| Memory leaks | `Timer` | 20 |
| Memory leaks | `Timer.periodic` | 30 |
| Memory leaks | `StreamController` | 25 |
| Memory leaks | `StreamSubscription` | 25 |
| Lifecycle | `setState in dispose` | 60 |
| Lifecycle | `setState in build` | 50 |
| Lifecycle | `setState in initState` | 35 |

## Gravity levels

| Score | Level |
|---|---|
| 0–20 | 🟢 LOW |
| 21–45 | 🟡 MEDIUM |
| 46–70 | 🟠 HIGH |
| 71–100 | 🔴 CRITICAL |

## CI/CD

```yaml
- name: Ren — Feature Gravity
  run: |
    dart pub global activate ren
    ren --format json > ren-report.json
    ren --fail-on high
```

## License

Apache 2.0 — see [LICENSE](LICENSE).