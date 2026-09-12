# Visual asset notes

The app has no runtime image or video download.

## Celestial artwork

The 20-body Android atlas was generated specifically for Solar System Explorer with OpenAI image generation, without text, logos, or watermarks. It was cropped into transparent 256 px PNG files for the Sun, major planets, Pluto, and ten important moons. The shared Flutter renderer adds lightweight animated clouds, bands, atmosphere, glow, and depth so the bodies remain alive across Solar System, Explore, Details, Stars, and Compare.

Prompt summary: create a scientifically recognizable, photorealistic 5 × 4 atlas on black in the exact order Sun, Mercury, Venus, Earth, Mars; Jupiter, Saturn, Uranus, Neptune, Pluto; Moon, Phobos, Deimos, Io, Europa; Ganymede, Callisto, Titan, Enceladus, Triton. Use consistent upper-left illumination, no text, no grid, no logos, no watermark, and clear phone-scale surface identity.

## Cinematic

The portrait intro MP4 was supplied by the project owner. The bundled Android copy preserves its original stereo 48 kHz AAC-LC audio and 9:16 framing, while normalizing delivery to an Android-friendly 720 × 1280 H.264 Constrained Baseline Level 3.1 stream at a constant 30 fps with fast-start metadata. This phone-optimized master lowers decoder memory and APK size without stretching the image. A local poster frame avoids a blank initialization flash.

## Scientific data

Visual artwork is educational representation, not a source for measurements. Physical diameters and comparison calculations continue to come from the curated catalog and the references in [data_sources.md](data_sources.md).
