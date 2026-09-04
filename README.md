# Solar System Explorer

Solar System Explorer is an interactive Flutter experience for exploring the Solar System, notable moons and dwarf planets, and some of the best-known stars in our galactic neighbourhood. It is designed to teach through motion, scale, concise facts, and direct visual comparison rather than long encyclopedia pages.

## Product goals

- A cinematic, responsive Solar System experience with user-controlled motion.
- Focused exploration of planets, dwarf planets, moons, asteroids, comets, and stars.
- Scientifically consistent diameter comparisons with explicit true-scale and readable modes.
- Smooth, performance-conscious animation with reduced-motion support.
- Local-first content with no backend, account, or network requirement.

## Included experiences

- **Live Solar System:** the Sun, eight planets, orbit paths, differentiated orbital motion, an asteroid belt, a passing comet, focus interactions, and 0.5×/1×/2×/4× playback controls.
- **Explore:** a responsive, searchable catalog of planets, dwarf planets, important moons, asteroids, comets, and the asteroid belt.
- **Stars:** a dedicated stellar catalog spanning Proxima Centauri through red and blue supergiants.
- **Body details:** a cinematic Hero transition, procedural rotating body, staged facts, scientifically relevant properties, and short field notes.
- **Scale laboratory:** reusable planet/moon/star/small-body comparison with an exact physical-diameter mode, shared camera zoom, and an explicitly labelled readable mode.
- **Accessibility:** high-contrast typography, semantic controls, 48 px interaction targets, and automatic reduced-motion behaviour when the platform requests it.

## Technology

- Flutter 3.44.8
- Dart 3.12.2
- Material 3
- Android-first, with Web and Windows project targets included

## Architecture

The project intentionally uses a compact feature-oriented Flutter structure: immutable models and local curated data are kept separate from comparison logic, screens, reusable widgets, and custom painters. No backend or heavyweight state-management dependency is required.

```text
lib/
├── animations/  # performant environmental motion
├── app/         # theme, navigation shell, and routes
├── core/        # tested physical comparison calculations
├── data/        # local curated scientific catalog
├── models/      # immutable celestial body definitions
├── screens/     # Solar System, Explore, Stars, Details, Compare
└── widgets/     # procedural bodies and reusable panels/cards
```

Animation is deliberately bounded: one slow background controller per active screen, one orbital controller in the simulation, deterministic low-count particles, isolated custom painting, no continuous blur, and no off-screen animated tab stack.

## Run locally

```bash
flutter pub get
flutter run
```

Useful build commands:

```bash
flutter build apk --debug
flutter build web --release
```

Quality checks:

```bash
flutter analyze
flutter test
```

## Scientific data and artwork

Numeric data is stored locally and uses standard NASA Solar System Exploration and NASA/IAU reference values, with approximate or variable stellar values labelled as such in the app. Visual bodies are original procedural Flutter artwork rather than external image assets, keeping the experience coherent, lightweight, and free of watermarks.

The comparison engine always calculates with **diameter in kilometres**. In true-scale mode both render sizes share one linear pixels-per-kilometre scale. When a very small body falls below a visible pixel, an independent locator ring may identify its position without enlarging the physical disk. Readable mode enforces a visible minimum and always displays `NOT TO SCALE`.

See [scientific data notes and primary references](docs/data_sources.md) for NASA/IAU links and the stellar-size uncertainty policy.

## Catalog coverage

- Sun and all eight major planets
- Pluto, Ceres, Eris, Haumea, and Makemake
- Moon, Phobos, Deimos, Io, Europa, Ganymede, Callisto, Titan, Enceladus, and Triton
- Asteroid Belt, Vesta, Bennu, Halley’s Comet, and Comet 67P
- Sun, Proxima Centauri, Sirius A, Vega, Polaris, Arcturus, Aldebaran, Rigel, Betelgeuse, Antares, Deneb, and UY Scuti

## Dependencies

The runtime uses the Flutter SDK and Material/Cupertino icon fonts only. No third-party animation, routing, state-management, networking, or rendering package is required.

## Verification

- `flutter analyze`: no issues found
- `flutter test`: model, catalog, true-scale mathematics, navigation, search, comparison labels, and compact Android viewport coverage
- Android: debug APK build verified
- Web: release build verified

## Status

STEP 1 is feature-complete locally. GitHub publication is pending authentication; the local Git repository and full commit history are ready to push.

## Known limits

- Orbital positions and interplanetary distances in the main simulation are intentionally visualized rather than presented to physical scale. Scientific scale applies only inside the Scale Laboratory.
- Stellar diameters are observational estimates and can change as measurements improve; approximate values are visibly labelled.
- The catalog is English-only in STEP 1.
- No Android emulator or physical Android device was connected during final verification; Android compilation and Flutter-rendered widget smoke tests were used instead.

## License

No license has been selected yet. All rights reserved by the project owner.
