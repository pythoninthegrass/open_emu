# AGENTS.md — OpenEmu-Silicon

Instructions for AI coding agents (Claude Code, Cursor, Copilot, etc.) working in this repository.

---

## Read First

Before doing any work, read this file fully. It is the authoritative source for how this project is structured and how changes should be made.

---

## About This Project

OpenEmu-Silicon is a community-maintained fork of OpenEmu, rebuilt to run natively on Apple Silicon (arm64) without Rosetta. It descends from:

- [OpenEmu/OpenEmu](https://github.com/OpenEmu/OpenEmu) — the original project
- [bazley82/OpenEmuARM64](https://github.com/bazley82/OpenEmuARM64) — the foundational ARM64 port

The goal is to honor the original OpenEmu spirit — a beautifully designed, first-class native macOS game emulation frontend — while making it work reliably on M-series Macs with modern macOS and Swift.

**The maintainer is not a professional developer.** If you are writing explanations, commit messages, or comments, please use plain language. Avoid jargon where a plain word works just as well.

---

## Ground Rules

1. **Never commit directly to `main`.** `main` is the stable release branch. All work goes through feature branches → `staging` → `main`.
2. **`staging` is the default development branch.** Branch from `staging`, open PRs against `staging`.
3. **Build before committing.** Run an `xcodebuild` check on any Swift/ObjC changes before staging a commit.
4. **Don't rewrite files wholesale.** This is a large, complex Xcode project. Make surgical changes. Rewriting `.pbxproj` or large ObjC files without understanding them will break the build.
5. **Respect the flattened architecture.** Submodule directories (`Nestopia/`, `BSNES/`, etc.) are regular directories — do not attempt to re-initialize them as git submodules.
6. **Do not commit build artifacts.** No `.o` files, derived data, `.app` bundles, build logs, or compiled executables.
7. **Note AI assistance in commit messages.** If a commit was written or significantly assisted by an AI tool (Claude, Cursor, Copilot, etc.), say so in the commit message. Example: `fix: resolve VICE dlopen crash (assisted by Claude Code)`.

---

## Language and Tooling

- **Swift 6.2.4** — strict concurrency is enforced. Use `@MainActor`, `Sendable`, and structured concurrency correctly.
- **Objective-C** — many core files are ObjC. Bridge headers are in place. Don't break them.
- **Xcode 26.3** — use `xcodebuild` for CLI builds. The primary workspace is `OpenEmu-metal.xcworkspace`.
- **No package manager** — no SPM, no CocoaPods, no Carthage. Dependencies are vendored or flattened submodules.

---

## Build Command

```bash
xcodebuild \
  -workspace OpenEmu-metal.xcworkspace \
  -scheme OpenEmu \
  -configuration Debug \
  -destination 'platform=macOS,arch=arm64' \
  build 2>&1 | tail -30
```

A clean build is the definition of "passing." Run this before every commit touching source files.

---

## File Organization

| What you're touching | Where it lives |
|----------------------|---------------|
| Main app logic | `OpenEmu/*.swift` and `OpenEmu/*.m` |
| Shared protocols/types | `OpenEmu-SDK/` |
| UI components | `OpenEmuKit/` |
| Metal shaders | `OpenEmu-Shaders/` |
| Emulator cores | `[CoreName]/` (top-level dirs) |
| Build and utility scripts | `Scripts/` |
| Xcode project | `OpenEmu/OpenEmu.xcodeproj/` |

---

## Supported Cores (as of 2026)

| System | Core |
|--------|------|
| Atari 2600 | Stella |
| Atari 5200 | Atari800 |
| Atari 7800 | ProSystem |
| Atari Lynx | Mednafen |
| ColecoVision | JollyCV |
| Commodore 64 | VICE |
| Famicom Disk System | Nestopia |
| Game Boy / GBC | Gambatte |
| Game Boy Advance | mGBA |
| Game Gear | Genesis Plus GX |
| Intellivision | Bliss |
| Nintendo (NES) | Nestopia, FCEU |
| Nintendo 64 | Mupen64Plus |
| Nintendo DS | DeSmuME |
| Odyssey² / Videopac+ | O2EM |
| Pokémon Mini | PokeMini |
| Sega 32X | picodrive |
| Sega CD / Mega CD | Genesis Plus GX |
| Sega Dreamcast | Flycast |
| Sega Genesis / Mega Drive | Genesis Plus GX |
| Sega Master System | Genesis Plus GX |
| Sega Saturn | Mednafen |
| Sony PlayStation | Mednafen |
| Super Nintendo (SNES) | BSNES, Snes9x |
| Vectrex | VecXGL |
| WonderSwan | Mednafen |
| 3DO | 4DO |

---

## PR Guidelines

- **Target branch:** `staging` on `chris-p-bacon-sudo/OpenEmu-Silicon`
- **PR title format:** `fix: description` / `feat: description` / `chore: description`
- **Use the PR template** — `.github/PULL_REQUEST_TEMPLATE.md` auto-populates when you open a PR on GitHub. Fill every section; don't delete the checklist.
- Each PR should address one issue or one logical change — don't bundle unrelated fixes
- For core-specific fixes, note which systems are affected and whether you tested with a ROM
- Reference the issue with `Fixes #N` (auto-closes on merge) or `Related to #N` (soft link)

---

## Issue Tracker

The issue tracker at `chris-p-bacon-sudo/OpenEmu-Silicon` is the primary place for bug reports, feature requests, and community feedback. It is not a mirror of an upstream tracker — this is the project's own issue log.

---

## What NOT to Do

- Do not modify `project.pbxproj` manually unless you know exactly what you're changing — it's a large generated file and merge conflicts are painful
- Do not add new dependencies without discussion — the project intentionally has no package manager
- Do not remove or rename existing core directories — they are referenced by the Xcode project
- Do not commit the `build_*.log` files that exist at root — they are legacy artifacts
- Do not change `MACOSX_DEPLOYMENT_TARGET` below `11.0` — this is the ARM64 baseline
- Do not commit `OEGoogleDriveSecrets.swift` — it is gitignored for a reason; it holds real OAuth credentials
- Do not add debug `+load` / `+initialize` methods that write to `/tmp` or hardcode local paths
- Do not commit large binaries (`.zip`, `.tar.gz`, compiled executables) — these belong in GitHub Releases
- Do not commit directly to `main` under any circumstances

---

## License Rules

The main app is **BSD 2-Clause**. Emulator cores are mostly **GPL v2**. Key rules:

1. **Preserve all copyright headers** — never strip or modify the license block at the top of any file
2. **Add a header to new files** you create in `OpenEmu/`, `OpenEmu-SDK/`, or `OpenEmuKit/`:
   ```
   // Copyright (c) 2026, OpenEmu Team
   //
   // Redistribution and use in source and binary forms, with or without
   // modification, are permitted provided that the following conditions are met:
   // ...
   ```
3. **picodrive is non-commercial** — never charge for a build that includes it
4. **No CLA** — your contributions are covered by the license of the files you touch

---

## Quick Reference

```bash
# Open in Xcode
open OpenEmu-metal.xcworkspace

# --- Start of every new piece of work ---
git checkout staging
git fetch origin && git merge origin/staging

# Create a feature branch
git checkout -b fix/your-description

# Build check before committing
xcodebuild -workspace OpenEmu-metal.xcworkspace -scheme OpenEmu \
  -configuration Debug -destination 'platform=macOS,arch=arm64' \
  build 2>&1 | tail -10

# Stage and commit (note AI tools used if applicable)
git add -p
git commit -m "fix: description (assisted by Claude Code)"

# Push and open PR against staging
git push -u origin fix/your-description
# Then open a PR on GitHub targeting staging
```
