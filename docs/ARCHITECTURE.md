# Architecture

This project follows a feature-first structure with shared `core/` utilities.

## Folder layout

- `lib/main.dart`: app entrypoint
- `lib/config/`: app-level configuration (router/theme)
- `lib/core/`: shared utilities (errors, i18n, network, theme, widgets)
- `lib/features/<feature>/`:
  - `data/`: repositories, DTOs, API/Firestore adapters
  - `domain/`: entities/value objects, business rules
  - `presentation/`: UI, controllers/providers, widgets
- `lib/services/`: cross-cutting services (e.g. logistics, secure storage)

## Guidelines

- Prefer putting Firestore/HTTP code behind repositories (`data/`) and expose typed domain entities (`domain/`).
- Keep widgets dumb: state and side-effects should live in Riverpod providers/controllers.
- Avoid doing heavy work in `build()`:
  - cache currency formatters
  - cache decoded base64 images (if you still store them)
  - avoid repeated parsing/decoding

## Testing strategy

- Unit tests: pure Dart logic (`core/utils`, `domain/` rules)
- Widget tests: key screens/widgets with mocked providers
- Integration tests: smoke test + Firebase-emulator-backed E2E (recommended)

## Performance notes

- Currency formatting and base64 decoding are cached to reduce GC/jank during scrolling.
- Prefer image URLs + CDN over storing base64 in Firestore documents.
