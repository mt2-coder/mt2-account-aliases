# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **README in seven more languages** — `README.de.md`, `README.es.md`, `README.fr.md`,
  `README.it.md`, `README.pt.md`, `README.ro.md` and `README.tr.md` translate the part of the
  README written for players (what the add-on does, why it is safe, install, uninstall,
  troubleshooting) and link to the English developer part, so that players can read it in their
  own language. Each gives the date of the English text it translates, and the English text
  prevails. A language line under every README's title links them together, and the archive's
  `README.txt`, which stays in English, lists them. The translations name the launcher's menus
  with its own labels in that language (Einstellungen > Spielaccount, Paramètres > Compte de jeu…)
  and say that the add-on's buttons and the installer's messages are in English.
- **Translated guides linked from the release notes** — the notes of every release open with a
  line linking to each README translation, since GitHub shows a single text per release and the
  rest of it stays in English. `release/build.py` refuses to build when its `TRANSLATIONS` list,
  the `README.<code>.md` files and the links in `README.txt` disagree, so that a new translation
  cannot be left out.

### Changed

- **README for players** — the README now opens with a readable title, the 42-second demo video
  playing in the page, what the add-on does and why it is safe (it never touches the game and
  only adds a layer over the launcher's interface), then how to install, uninstall and
  troubleshoot it. The technical
  part comes last, for contributors and for Gameforge's teams, with notes on building the feature
  into the launcher itself. Players were landing on a page written for developers.

## [0.1.0] - 2026-10-03

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
  runs, and recognises a pak replaced by a launcher update. It finds the launcher in whatever
  folder it was installed, from its uninstall entry or its Windows service, and otherwise says how
  to give the path. It runs on Windows PowerShell 5.1 and PowerShell 7; .NET's ZIP update mode
  was ruled out because it corrupts an empty entry of the pak under Windows PowerShell 5.1. The
  elevated relaunch passes `-ExecutionPolicy Bypass`: it does not inherit the caller's policy, and
  Windows' default policy would otherwise refuse the script.
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
- **Release archive** — players download a ZIP from the repository's releases instead of cloning
  it: `Install.cmd`, `Uninstall.cmd` and `Status.cmd` run the installer with a double-click, and
  `README.txt` is their guide, down to the security warning Windows shows before running these
  unsigned files and how to avoid it. `release/build.py` builds it; the `Release` workflow runs it on
  GitHub, attests the archive's provenance and opens a draft release, so the archive comes from
  the public code and nothing is public before it has been checked.

[Unreleased]: https://github.com/mt2-coder/mt2-account-aliases/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mt2-coder/mt2-account-aliases/releases/tag/v0.1.0
