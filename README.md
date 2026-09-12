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
- **Cold-start cinematic:** an Android-only, locally bundled portrait film with synchronized audio, lifecycle-safe pause/resume, and failure-safe entry to the main experience.
- **Accessibility:** high-contrast typography, semantic controls, 48 px interaction targets, and automatic reduced-motion behaviour when the platform requests it.

## Technology

- Flutter 3.44.8
- Dart 3.12.2
- Material 3
- Android phone is the final production target; Web and Windows remain development targets

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
└── widgets/     # shared body rendering and reusable panels/cards
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

Numeric data is stored locally and uses standard NASA Solar System Exploration and NASA/IAU reference values, with approximate or variable stellar values labelled as such in the app.

Major planets, Pluto, the Sun, and ten important moons use bundled 256 px transparent artwork generated specifically for this project with OpenAI image generation, then normalized for consistent phone rendering. Deterministic Flutter overlays retain atmospheric motion, glow, depth, and body-specific details; unbundled objects and stars retain the lightweight procedural renderer. No surface asset is downloaded at runtime.

The 512 px launcher artwork in `assets/branding/` was also generated specifically for this project with OpenAI image generation. The bundled cinematic in `assets/video/` was supplied by the project owner. Its Android delivery copy is 1080×1920 H.264 Main at a constant 30 fps with the original stereo AAC track retained, plus a local first-frame poster to prevent a loading flash. See [visual asset notes](docs/visual_assets.md).

The comparison engine always calculates with **diameter in kilometres**. In true-scale mode both render sizes share one linear pixels-per-kilometre scale. When a very small body falls below a visible pixel, an independent locator ring may identify its position without enlarging the physical disk. Readable mode enforces a visible minimum and always displays `NOT TO SCALE`.

See [scientific data notes and primary references](docs/data_sources.md) for NASA/IAU links and the stellar-size uncertainty policy.

## Catalog coverage

- Sun and all eight major planets
- Pluto, Ceres, Eris, Haumea, and Makemake
- Moon, Phobos, Deimos, Io, Europa, Ganymede, Callisto, Titan, Enceladus, and Triton
- Asteroid Belt, Vesta, Bennu, Halley’s Comet, and Comet 67P
- Sun, Proxima Centauri, Sirius A, Vega, Polaris, Arcturus, Aldebaran, Rigel, Betelgeuse, Antares, Deneb, and UY Scuti

## Dependencies

The only added runtime plugin is Flutter's official `video_player`, used for the local Android cold-start cinematic. No third-party animation, routing, state-management, networking, or rendering package is required.

## Verification

- `flutter analyze`: no issues found
- `flutter test`: 25/25 tests passed, covering the catalog, true-scale mathematics, navigation, search, Details → Compare, reduced motion, enlarged text, and 320/360/390 px Android viewports
- Android: release APK build and Pixel 3a / Android 16 emulator smoke test verified
- Intro and lifecycle: process-local cold-start playback, no replay on resume, safe background pause/resume, and immediate decoder-failure fallback

## Status

STEP 1 and the Android-focused STEP 2 production polish are complete. The source and full commit history are published at [github.com/saaed2010/Solar-System-Explorer](https://github.com/saaed2010/Solar-System-Explorer).

## Known limits

- Orbital positions and interplanetary distances in the main simulation are intentionally visualized rather than presented to physical scale. Scientific scale applies only inside the Scale Laboratory.
- Stellar diameters are observational estimates and can change as measurements improve; approximate values are visibly labelled.
- The catalog is English-only in STEP 1.
- The cinematic is intentionally portrait-only, matching the Android phone product scope.
- No physical Android handset was available for final speaker/video sign-off. The bundled cinematic fully decodes offline, but the available Android 16 emulator's `c2.goldfish.h264.decoder` crashes independently of profile, resolution, and H.264 compatibility level; the app correctly takes its immediate startup fallback in that environment.

## License

No license has been selected yet. All rights reserved by the project owner.
