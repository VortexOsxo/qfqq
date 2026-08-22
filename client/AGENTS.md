# AGENTS.md

## Project

QFQQ is a Flutter application for small companies to track decisions and tasks across projects.

The application targets:

- Android
- iOS
- Windows
- macOS

The frontend communicates with a Flask backend.

## Core Principles

- Keep solutions simple and concise.
- Prefer the simplest solution that solves the problem.
- Avoid unnecessary abstractions, patterns, and complexity.
- Reuse existing code and patterns before creating new ones.
- Make focused changes. Do not modify unrelated code.
- When something is unclear, inspect the existing code before making assumptions.
- Keep the UI simple and professional. Avoid anything flashy or over-engineered.

## Architecture

The main application code is organized under `lib/`:

Keep platform-independent functionality in `common/` when possible.

Use `desktop/` and `mobile/` for platform-specific functionality.

Do not reorganize the project structure unless there is a clear reason to do so, in which case prompt the user before doing so.

## Flutter

- Use Riverpod for state management.
- Use `go_router` for navigation.
- Follow the existing Flutter patterns in the project.
- Build interfaces that work appropriately on both mobile and desktop.
- Prefer existing Flutter widgets and project components before creating new ones.

## Localization

Translations use Flutter Intl with ARB source files.

Files to modify when adding or changing translations:

- `lib/l10n/intl_en.arb` for English.
- `lib/l10n/intl_fr.arb` for French.

After modifying an ARB file, regenerate the Dart localization files with:

```text
dart run intl_utils:generate
```

The generated files are written to `lib/generated/`. Do not edit generated files
manually; they will be overwritten the next time the generation command runs.

Use `S.of(context)` in widgets and import `package:qfqq/generated/l10n.dart`.
For code without a `BuildContext`, use `S.current` when the localization delegate
has already been initialized.

Keep the same translation key in every locale file. For messages with placeholders,
declare the placeholder in the ARB value, for example `Meeting on {date}`, and use
the generated method with the corresponding argument.

## Backend Communication

The application communicates with the Flask backend using the `http` package.

Use the existing `QfqqHttpClient` for API communication.

Do not create new `http.Client` instances or alternative API clients unless there is a specific reason.

The existing HTTP client is responsible for common request behavior such as:

- Authentication headers
- API version headers
- Locale headers
- Authentication state changes
- API URL configuration

Follow the existing patterns when adding new API calls.

## Dependencies

Before adding a new dependency:

1. Explain why the dependency is needed.
2. Ask the user for permission.
3. Only add it after the user approves.

Prefer existing dependencies and Flutter/Dart functionality when they are sufficient.

## Testing

Tests are not required for this project.

## Generated Files

Do not manually modify generated files unless explicitly requested.

Prefer changing the source/configuration that generates them.

## Code Changes

Before implementing a change:

1. Inspect the relevant existing code.
2. Follow existing conventions.
3. Make the smallest reasonable change.
4. Avoid unrelated refactoring.

Do not introduce a new architecture or design pattern simply because it is theoretically cleaner.

When multiple solutions are possible, prefer the simpler and more concise solution.