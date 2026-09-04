# Solar System Explorer

Solar System Explorer is an interactive Flutter experience for exploring the Solar System, notable moons and dwarf planets, and some of the best-known stars in our galactic neighbourhood. It is designed to teach through motion, scale, concise facts, and direct visual comparison rather than long encyclopedia pages.

## Product goals

- A cinematic, responsive Solar System experience with user-controlled motion.
- Focused exploration of planets, dwarf planets, moons, asteroids, comets, and stars.
- Scientifically consistent diameter comparisons with explicit true-scale and readable modes.
- Smooth, performance-conscious animation with reduced-motion support.
- Local-first content with no backend, account, or network requirement.

## Technology

- Flutter 3.44.8
- Dart 3.12.2
- Material 3
- Android-first, with Web and Windows project targets included

## Architecture

The project intentionally uses a compact feature-oriented Flutter structure: immutable models and local curated data are kept separate from comparison logic, screens, reusable widgets, and custom painters. No backend or heavyweight state-management dependency is required.

## Run locally

```bash
flutter pub get
flutter run
```

Quality checks:

```bash
flutter analyze
flutter test
```

## Scientific data and artwork

Numeric data is stored locally and uses standard NASA Solar System Exploration and NASA/IAU reference values, with approximate or variable stellar values labelled as such in the app. Visual bodies are original procedural Flutter artwork rather than external image assets, keeping the experience coherent, lightweight, and free of watermarks.

## Status

STEP 1 foundation initialized. Feature implementation is in progress.

## License

No license has been selected yet. All rights reserved by the project owner.
