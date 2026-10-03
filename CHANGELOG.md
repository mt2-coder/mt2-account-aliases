# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Account aliases in the launcher** — `src/alias-addon.js` puts a pencil next to every account
  name in Settings > Game account and shows the alias followed by the id in small grey type. The
  launcher names game accounts with generated ids (`playerg123456789`), and with dozens of them
  finding the right one meant memorising ids. The alias shares the id's line and long aliases are
  cut on screen: the Settings window has a fixed size, and taller rows made it scroll.
- **Search by alias** — the launcher's own search box also finds accounts by alias, and its
  pagination keeps working, because the add-on hands the launcher a regex covering both the typed
  text and the matching ids instead of filtering rows itself.
- **Backup and restore of aliases** — the **Manage** panel copies and applies the aliases as JSON,
  since they live in the launcher's local storage on one PC only.
- **Settings popup support** — the add-on wraps `window.open` and decorates every window the
  launcher opens. The account list is a popup that the main page fills itself, so a script that
  only watched its own page never saw a single account.
- **Installer** — `scripts/alias-addon.ps1` with `status`, `install` and `revert`. It keeps a
  verified backup of `frontend.pak`, rewrites the archive byte for byte so that only `index.html`
  changes, swaps the file in one step, relaunches itself through UAC, refuses while the launcher
  runs, and recognises a pak replaced by a launcher update. It runs on Windows PowerShell 5.1 and
  PowerShell 7; .NET's ZIP update mode was ruled out because it corrupts an empty entry of the pak
  under Windows PowerShell 5.1.
- **Diagnostic mode** — `install -Diagnostic` shows, without devtools, whether the launcher displays
  the patched page, runs the script and finds the accounts. It is how the popup was found.
- **Tests** — unit tests of the pure helpers (`test/logic.test.cjs`) and a look-alike of the
  launcher's Settings popup (`test/mock-launcher.html`), with a self-test mode (`?auto`).
- **Documentation** — `README.md` (install, use, launcher updates, troubleshooting), `CLAUDE.md`
  (frozen decisions, verified launcher facts, hard rules, privacy, traps) and
  `docs/launcher-internals.md`, how the launcher works as far as the add-on is concerned.
- **Repository settings** — `.gitattributes` keeps every file LF in every checkout, because
  `status` compares the add-on's sha256 with the one recorded in the launcher and Git for
  Windows' CRLF conversion would make an unchanged add-on look modified. `.gitignore` keeps copies
  of `frontend.pak`, the installer's backup and temporary files, and personal notes
  (`CLAUDE.local.md`) out of the repository.
- **MIT licence** — `LICENSE`, so that other players may use, change and share the add-on. It
  covers this repository only, not Gameforge's files.
