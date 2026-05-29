# CLAUDE.md

## Project structure

Flutter source is split by responsibility under `lib/`:

```text
lib/
  main.dart                         # app bootstrap only
  app/                              # app shell, top-level view switching, placeholders
  controllers/                      # game state and user actions
  core/                             # app constants, colors, asset helpers
  models/                           # pure data classes and enums
  repositories/                     # static story/content data
  screens/                          # full-page UI screens
    collection/
    story/
  stores/                           # progress persistence abstraction and implementations
  widgets/                          # reusable UI pieces
    collection/
```

## Refactor rules

- Prefer built-in Claude Code file tools (`Read`, `Write`, `Edit`, `Glob`, `Grep`) before ad-hoc shell scripts.
- If automation is needed in this Dart/Flutter project, prefer project-native Dart over Python/Node/Perl.
- Avoid Python/Node/Perl extraction scripts unless clearly safer, installed, small, and easy to verify.
- For file splits/refactors: inspect current state first, edit in small batches, then run `dart format` and `flutter analyze`.

## Verification

After Dart source changes, run:

```bash
dart format lib test
flutter analyze
```

Current refactor verification result: `flutter analyze` reports `No issues found!`.
