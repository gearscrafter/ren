# REN

> Flutter Feature Gravity Analyzer

[![pub version](https://img.shields.io/pub/v/ren.svg)](https://pub.dev/packages/ren)
[![pub points](https://img.shields.io/pub/points/ren.svg)](https://pub.dev/packages/ren/score)
[![license](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![platform](https://img.shields.io/badge/platform-dart-blue.svg)](https://dart.dev)

**ren** detects performance risk in your Flutter features before you ship —
analyzing costly AST patterns, widget combinations, and lifecycle misuse
to report a gravity score per feature, without running the app.

> **ren** is not a replacement for `flutter analyze` or DevTools.
> It occupies a different space:
>
> | Tool | Answers |
> |---|---|
> | `flutter analyze` | Quality and errors |
> | DevTools | Runtime performance |
> | `ren` | Which features carry the most performance risk — before you run anything |


---

## Installation

```bash
dart pub global activate ren
```

> **Windows (PowerShell):** `ren` conflicts with the built-in `Rename-Item` alias.
> Use `renw` instead, or run `Remove-Item Alias:ren -Force` once per session.

---

## Usage

```bash
# Analyze the current project
ren

# Analyze a specific path
ren --project ./my_app

# Custom feature root (for projects not using lib/features/)
ren --project ./my_app --features lib/ui/screens

# Exclude generated or internal paths
ren --project ./my_app --exclude lib/generated,lib/_tools

# JSON output for CI/CD
ren --format json > ren-report.json

# Fail pipeline if any feature reaches HIGH or above
ren --fail-on high
```

---

## Example output

```
  ◈ ren  · Flutter Feature Gravity Analyzer
  ────────────────────────────────────────────────────────────
  ◦ checkout             ●●●●●  CRITICAL  100%
    ↳ BackdropFilter     [inside ListView]  BackdropFilter inside ListView is one of the worst Flutter performance patterns.
    ↳ Opacity            [inside ListView]  Opacity inside ListView creates an offscreen layer per visible item.
    ↳ ShaderMask         Runs a shader on every frame — high GPU cost.

    Top contributors:
    BackdropFilter ················ +100
    Opacity ······················· +50
    ShaderMask ···················· +35

  ◦ home                 ●●●○○  HIGH       65%
    ↳ setState in build  Calling setState inside build triggers infinite rebuild loop.
    ↳ MediaQuery.of      Rebuilds on any MediaQuery change — prefer MediaQuery.sizeOf.

    Top contributors:
    setState in build ············· +50
    MediaQuery.of ················· +15

  ◦ profile              ○○○○○  LOW        12%
    ↳ NetworkImage       No caching by default — prefer CachedNetworkImageProvider.
  ────────────────────────────────────────────────────────────
  3 feature(s) · 6 pattern(s) detected
```

---

## ren.yaml

Place a `ren.yaml` at your project root to avoid passing flags every time:

```yaml
# Custom feature root
features: lib/ui/screens

# Fail CI/CD if any feature reaches this level
fail_on: high

# Paths to exclude
ignore:
  - lib/generated
  - lib/l10n
  - lib/_tools

# Override built-in weights (0 = disable rule)
weights:
  Opacity: 0          # our team uses Opacity correctly
  ListView: 0         # not a concern for our use case
  BackdropFilter: 60  # we want to be extra strict

# Team-specific patterns
custom_rules:
  - name: MyHeavyWidget
    reason: Internal widget known to cause jank in production.
    weight: 45
```

CLI flags always take priority over `ren.yaml`.

---

## How it works

ren scans your project's Dart source files using the `analyzer` package,
visits the AST of each file, and detects patterns known to cause performance
issues in Flutter apps.

Each pattern carries a base weight. When a costly pattern is found **inside
another costly widget**, the weight is multiplied:

| Level | Example | Multiplier |
|---|---|---|
| Presence | `Opacity` found | ×1.0 |
| Context | `NetworkImage` inside `ListView` | ×1.5 |
| Risk | `BackdropFilter` inside `ListView` | ×2.5 |

The total weight per feature is normalized to a 0–100 gravity score.

If no feature root is found (`lib/features/`, `lib/modules/`), ren falls back
to treating `lib/` as a single feature — so it always produces output regardless
of your project structure.

---

## Detected patterns

### Base patterns

| Category | Pattern | Weight |
|---|---|---|
| GPU | `saveLayer` | 50 |
| GPU | `BackdropFilter` | 40 |
| GPU | `ShaderMask` | 35 |
| GPU | `ImageFiltered` | 35 |
| GPU | `ClipPath` | 25 |
| GPU | `Opacity` | 20 |
| GPU | `ColorFiltered` | 20 |
| GPU | `CustomPaint` | 20 |
| GPU | `ClipRRect` | 15 |
| Lists | `SingleChildScrollView` | 20 |
| Lists | `ListView` | 15 |
| Lists | `GridView` | 15 |
| Lists | `Wrap` | 15 |
| Images | `Image.network` | 25 |
| Images | `NetworkImage` | 25 |
| Images | `FadeInImage` | 15 |
| Rebuilds | `MediaQuery.of` | 15 |
| Rebuilds | `Hero` | 20 |
| Rebuilds | `RepaintBoundary` | 5 |
| Memory leaks | `Timer.periodic` | 30 |
| Memory leaks | `StreamController` | 25 |
| Memory leaks | `StreamSubscription` | 25 |
| Memory leaks | `Timer` | 20 |
| Lifecycle | `setState in dispose` | 60 |
| Lifecycle | `setState in build` | 50 |
| Lifecycle | `setState in initState` | 35 |

### Compound patterns (elevated weight)

| Level | Combination | Weight |
|---|---|---|
| 🔴 Risk | `BackdropFilter` inside `ListView` / `GridView` | +100 |
| 🔴 Risk | `ShaderMask` / `ImageFiltered` inside `ListView` / `GridView` | +87 |
| 🔴 Risk | `Opacity` inside `AnimatedBuilder` / `ListView` / `GridView` | +50 |
| 🔴 Risk | `ClipPath` inside `AnimatedBuilder` | +62 |
| 🔴 Risk | `ColorFiltered` inside `ListView` / `GridView` | +50 |
| 🟡 Context | `BackdropFilter` inside `Stack` / `PageView` | +60 |
| 🟡 Context | `NetworkImage` inside `ListView` / `GridView` | +37 |
| 🟡 Context | `CustomPaint` inside `AnimatedBuilder` / `ListView` / `GridView` | +30 |
| 🟡 Context | `ClipPath` inside `ListView` / `GridView` | +37 |
| 🟡 Context | `Hero` inside `ListView` / `GridView` | +30 |
| 🟡 Context | `ShaderMask` inside `AnimatedBuilder` | +52 |

---

## Gravity levels

| Score | Level |
|---|---|
| 0–20 | 🟢 LOW |
| 21–45 | 🟡 MEDIUM |
| 46–70 | 🟠 HIGH |
| 71–100 | 🔴 CRITICAL |

---

## CI/CD

```yaml
- name: Ren — Feature Gravity
  run: |
    dart pub global activate ren
    ren --format json > ren-report.json
    ren --fail-on high
```

---

## License

Apache 2.0 — see [LICENSE](LICENSE).