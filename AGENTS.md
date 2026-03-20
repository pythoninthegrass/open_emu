# AGENTS.md — OpenEmuARM64

Instructions for AI coding agents (Claude Code, Cursor, Copilot, etc.) working in this repository.

---

## Read First

Before doing any work, read `.claude/CLAUDE.md` for full project context, repo structure, build instructions, and known work areas.

---

## Ground Rules

1. **Never commit directly to `master`.** Always work on a feature branch (`fix/description` or `feat/description`).
2. **Build before committing.** Run an `xcodebuild` check on any Swift/ObjC changes before staging a commit.
3. **Don't rewrite files wholesale.** This is a large, complex Xcode project. Make surgical changes. Rewriting `.pbxproj` or large ObjC files without understanding them will break the build.
4. **Respect the flattened architecture.** Submodule directories (`Nestopia/`, `BSNES/`, etc.) are regular directories — do not attempt to re-initialize them as git submodules.
5. **Do not commit build artifacts.** No `.o` files, derived data, `.app` bundles, or build logs.

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
| Build scripts | `Scripts/` |
| Xcode project | `OpenEmu/OpenEmu.xcodeproj/` |

---

## PR Guidelines

- Target branch: `master` on `bazley82/OpenEmuARM64` (upstream)
- PR title format: `fix: description` / `feat: description` / `chore: description`
- **Use the PR template** — `.github/PULL_REQUEST_TEMPLATE.md` auto-populates when you open a PR on GitHub. Fill every section; don't delete the checklist.
- Each PR should address one issue or one logical change — don't bundle unrelated fixes
- For core-specific fixes, note which systems are affected and whether you tested with a ROM
- Reference the upstream issue with `Fixes #N` (auto-closes on merge) or `Related to #N` (soft link)
- You cannot apply labels to the upstream repo directly — suggest the appropriate label in your PR description or a comment; the maintainer applies it

**If your fix commit is on `master` mixed with other commits, cherry-pick it onto a clean branch:**
```bash
git checkout <last-upstream-commit-sha> -b fix/your-description
git cherry-pick <fix-commit-sha>
git push -u origin fix/your-description
gh pr create --repo bazley82/OpenEmuARM64 --head chris-p-bacon-sudo:fix/your-description --base master
```

---

## Issue Tracker

**Do not mirror upstream issues** into `chris-p-bacon-sudo/OpenEmuARM64`. They already exist at `bazley82/OpenEmuARM64/issues` and duplicating them creates maintenance overhead.

**Your fork's issue tracker is for personal working notes only:**
- Things you notice while testing that aren't ready to share upstream
- Ideas to revisit later
- Questions to answer before opening a PR

```bash
# Log a personal working note
gh issue create --repo chris-p-bacon-sudo/OpenEmuARM64 \
  --title "note: ..." \
  --body "..."
```

**When ready to surface something upstream**, file a new issue at `bazley82/OpenEmuARM64/issues` — don't just convert your fork note.

---

## What NOT to Do

- Do not modify `project.pbxproj` manually unless you know exactly what you're changing — it's a large generated file and merge conflicts are painful
- Do not add new dependencies without discussion — the project intentionally has no package manager
- Do not remove or rename existing core directories — they are referenced by the Xcode project
- Do not commit the `build_*.log` files that exist at root — they are legacy artifacts pending cleanup
- Do not change `MACOSX_DEPLOYMENT_TARGET` below `11.0` — this is the ARM64 baseline
- Do not commit `OEGoogleDriveSecrets.swift` — it is gitignored for a reason; it holds real OAuth credentials
- Do not add debug `+load` / `+initialize` methods that write to `/tmp` or hardcode local paths — this was a known issue that has been fixed
- Do not commit large binaries (`.zip`, `.tar.gz`, compiled executables) — these belong in GitHub Releases

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
git checkout master
git fetch upstream && git merge upstream/master
git push origin master                        # keep fork in sync

# Create a feature branch
git checkout -b fix/your-description

# Stage and commit
git add -p                                    # review changes interactively
git commit -m "fix: description"

# Push and open PR against upstream
git push -u origin fix/your-description
gh pr create --repo bazley82/OpenEmuARM64 \
  --head chris-p-bacon-sudo:fix/your-description \
  --base master

# --- After PR is merged upstream ---
git checkout master
git fetch upstream && git merge upstream/master
git push origin master
git branch -d fix/your-description
git push origin --delete fix/your-description

# Log a personal working note on your fork
gh issue create --repo chris-p-bacon-sudo/OpenEmuARM64 \
  --title "note: ..." --body "..."

# Check upstream open issues
gh issue list --repo bazley82/OpenEmuARM64
```
