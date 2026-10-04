# Metin2 Account Aliases

**English** · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) ·
[Italiano](README.it.md) · [Português](README.pt.md) · [Română](README.ro.md) · [Türkçe](README.tr.md)

[![Latest release](https://img.shields.io/github/v/release/mt2-coder/mt2-account-aliases?color=blue)](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
[![License: MIT](https://img.shields.io/github/license/mt2-coder/mt2-account-aliases)](LICENSE)
[![Tests](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml/badge.svg)](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml)
[![Provenance: attested](https://img.shields.io/badge/provenance-attested-brightgreen)](https://github.com/mt2-coder/mt2-account-aliases/attestations)

**Give your Metin2 accounts readable names in the Gameforge Client, and find them by name.**

A game account can never be renamed, and on the Tigerghost server the launcher even names them
with generated ids such as `playerg123456789`. With dozens of accounts listed four per page,
finding the right one is guesswork. This free add-on lets you call them `main`, `buff` or `meley1`
instead, right in the launcher's own account list.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Watch the demo on YouTube](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[Download the latest version](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
free and open source ([MIT](LICENSE))

> Unofficial add-on: not affiliated with or endorsed by Gameforge.

## What it does

In the launcher, **Settings > Game account**:

- **Name your accounts.** The pencil next to an account name gives it an alias: Enter saves,
  Escape cancels, an empty alias removes it. The alias comes first, the real name next to it in
  small grey type; a long alias is cut on screen and shown whole in the tooltip.
- **Find them by name.** The launcher's own search box (the magnifier above the table) also finds
  accounts by alias, and its pages keep working.
- **Keep a backup.** The **Manage** button, bottom right, shows all your aliases as text: copy it
  to keep a backup, or paste it and press **Apply** to restore it or move your aliases to another
  PC.

## Is it safe?

The add-on is built around one rule: never put your game or your account at risk.

- **It never touches the game.** Not `metin2client.exe`, not a single file of the game, not its
  anti-cheat. Nothing runs inside the game.
- **It is only a layer over the launcher's window.** The launcher's interface is a web page stored
  in one file, `resources\frontend.pak`. The add-on adds a small script to that page and nothing
  else: the launcher's program, and the way it starts the game, stay exactly the same.
- **Your account is left alone.** Aliases exist on your PC only: your real account names never
  change, neither on your PC nor on Gameforge's servers. The add-on makes no network request at
  all and never reads your password, your session or your account data; it only reads the account
  names already on screen.
- **You can undo it at any time.** The installer backs up the launcher's file before changing it,
  and `Uninstall.cmd` puts the original back, byte for byte.
- **Nothing is hidden.** No `.exe`: the add-on is one JavaScript file you can read,
  [`src/alias-addon.js`](src/alias-addon.js), and the installer one PowerShell script,
  [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Each release is built by GitHub from this
  public code and comes with its SHA-256 and a
  [provenance attestation](https://github.com/mt2-coder/mt2-account-aliases/attestations).

The add-on is free software under the MIT licence, which means it comes without warranty.

## Install

You need Windows 10 or 11, the Gameforge Client and administrator rights.

1. Download and extract `mt2-account-aliases-x.y.z.zip` from the
   [latest release](https://github.com/mt2-coder/mt2-account-aliases/releases/latest).
2. Close Metin2 and the Gameforge Client, including its icon in the notification area.
3. Double-click **`Install.cmd`**. If Windows asks, click **Run**, then **Yes**.
4. Start the launcher and open **Settings > Game account**.

The installer finds the launcher wherever it is installed. Checked with Gameforge Client
2.8.5.1959 (interface 0.486.2).

Your aliases are kept by the launcher, on this PC only. Anything that clears the launcher's data
would lose them, so keep a backup with **Manage**.

## Uninstall

Close the launcher, then double-click **`Uninstall.cmd`**: the launcher's original file comes back,
byte for byte. Your aliases stay stored in the launcher, so installing again brings them back.

## When the launcher updates its interface

The launcher cannot update an interface that the add-on has modified. When it announces an update,
or says it could not apply one:

1. close it, then double-click `Uninstall.cmd`;
2. start the launcher, let it update, then close it;
3. double-click `Install.cmd` again.

## Troubleshooting

- **What is installed?** `Status.cmd` tells you, and changes nothing.
- **"Gameforge Client not found".** Open a command prompt in the extracted folder (type `cmd` in
  File Explorer's address bar, then Enter) and give the path of the launcher's `frontend.pak`:
  `Install.cmd -PakPath "D:\Games\GameforgeClient\resources\frontend.pak"`.
- **No pencils in the account list.** Run `Install.cmd -Diagnostic` the same way. A small label
  appears at the bottom left of the launcher's main window and says how far the add-on got:

  | Label | Meaning |
  | --- | --- |
  | none at all | the launcher did not display the modified page |
  | red, `script did not run` | the page is displayed, but the add-on never ran |
  | `active - no account on screen`, with the account list open | the add-on runs but finds no account |
  | `active - 4 account(s) on screen (2 windows)` | the account list is found and decorated |
  | `... error (...): ...` | the message says what failed |

  `Install.cmd` without `-Diagnostic` removes the label.
- **The launcher switched to another language.** The add-on has nothing to do with it: the globe
  icon at the top right of the launcher sets it back.

---

## For developers and Gameforge's teams

Everything below is technical. It is meant for contributors, and for Gameforge's teams should they
want to offer this feature in the launcher itself, where it would need no add-on at all. Read
[CLAUDE.md](CLAUDE.md) before changing anything: frozen decisions, verified facts about the
launcher, hard rules and known traps.

### How it works

The launcher's interface is a web app packed in `resources\frontend.pak`, a plain ZIP. The
installer backs that file up, then inlines [`src/alias-addon.js`](src/alias-addon.js) as a
`<script>` at the end of its `index.html`, between marker comments. The Settings window is a popup
that the main page opens and fills by itself, so the add-on intercepts `window.open` to reach it.

The add-on makes no network request, never reads the session token, cookies or account data,
reads only the account names already on screen, and only adds attributes and its own overlay to
the page: it never writes into the nodes React owns. That one file is the whole trust surface.

`install` keeps the untouched original next to it as `frontend.pak.alias-backup`, rewrites the
archive so that only `index.html` changes, checks that every other entry is unchanged, then swaps
the file in one step. The launcher patches `frontend.pak` with binary deltas (xdelta3), which
cannot apply to a modified file: hence the uninstall, update, install sequence above.

### Building it into the launcher

The launcher already has what the feature needs; [docs/launcher-internals.md](docs/launcher-internals.md)
details it.

- **Where.** The game account table (`Br.DataTable`, `pageSize: 4`) renders each name in a
  `DataTable.Cell` with `id="QA_MenuSettings_GameAccount_Selection"` and `value=displayName`.
- **Search.** `filterRows` tests `new RegExp(filterValue, "i")` against each cell's `value`.
  Matching aliases too is what the add-on emulates: it hands the search
  `<query>|^(<ids whose alias matches>)$`.
- **Storage.** An alias is the player's own label for one game account and never replaces its
  real name. The add-on keeps a `{ "<id>": "<alias>" }` map in the launcher's local storage; a
  native version could keep it with the Gameforge account, so that it follows the player from PC
  to PC.
- **Display.** Alias first, id next to it as secondary text, on a single line: the Settings window
  has a fixed size, and taller rows make it scroll.

### From a clone

The `.cmd` files are in [`release/`](release/), or call the installer directly, with Windows
PowerShell 5.1 or PowerShell 7:

```powershell
.\scripts\alias-addon.ps1 status    # changes nothing: what is installed, backup state
.\scripts\alias-addon.ps1 install   # installs, or updates after an edit of src/alias-addon.js
.\scripts\alias-addon.ps1 revert    # restores the original frontend.pak byte for byte
```

If script execution is blocked on the machine, run
`powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\alias-addon.ps1 install`.
`-PakPath` points the script at another copy of `frontend.pak`, and `-AddonPath` at another add-on
file; both are how it is tested.

### Tests

```powershell
node test\logic.test.cjs
python -m http.server 8000 --bind 127.0.0.1
```

With the server running, open <http://127.0.0.1:8000/test/mock-launcher.html> and click
**Settings**: as in the launcher, the account list opens in a popup that the main page fills, and
the add-on decorates it. Adding `?auto` to the URL runs a self-test and writes its result in the
page; [CLAUDE.md](CLAUDE.md#testing) describes the headless run and how the installer is tested.

A change to the installer is tested against a copy of `frontend.pak` (`-PakPath`) before it goes
anywhere near the real launcher.

GitHub runs the unit tests on every push to `main` and every pull request
([`tests.yml`](.github/workflows/tests.yml)); the Tests badge at the top shows the last result.

### Releasing

1. In `CHANGELOG.md`, turn `## [Unreleased]` into `## [x.y.z] - <date>`, open a new empty
   `## [Unreleased]` above it, update the links at the bottom, and commit
   `chore(release): x.y.z` on `main`.
2. On GitHub, **Actions > Release > Run workflow** with the version `x.y.z`. The workflow runs the
   unit tests, builds the archive with `release/build.py`, attests its provenance and opens a
   **draft** release with the archive, its SHA-256 and notes taken from the changelog.
3. Download the draft's archive and try it on a PC that has never run the repository.
4. Publish the draft. Only then is the `vx.y.z` tag created, on the commit the workflow built.

To check the archive locally: `python release/build.py x.y.z dist` (the version needs its
changelog section).

### Layout

| Path | Content |
| --- | --- |
| [`src/alias-addon.js`](src/alias-addon.js) | the add-on, the only code that runs inside the launcher |
| [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1) | the installer: `status`, `install`, `revert`, `-Diagnostic` |
| [`release/`](release/) | what the players' archive adds (`.cmd` files, `README.txt`) and `build.py`, which builds it |
| [`.github/workflows/release.yml`](.github/workflows/release.yml) | builds the archive on GitHub and opens a draft release |
| [`.github/workflows/tests.yml`](.github/workflows/tests.yml) | runs the unit tests on every push to `main` and every pull request |
| [`test/logic.test.cjs`](test/logic.test.cjs) | unit tests of the add-on's pure helpers, for Node |
| [`test/mock-launcher.html`](test/mock-launcher.html) | look-alike of the launcher's Settings popup, to run the add-on in a browser |
| [`docs/`](docs/) | how the launcher works, as far as the add-on is concerned |
| [`CLAUDE.md`](CLAUDE.md) | context, frozen decisions, rules and traps: read it first |
| [`CHANGELOG.md`](CHANGELOG.md) | what changed, and why |
| [`LICENSE`](LICENSE) | the MIT licence |

## Licence

[MIT](LICENSE). It covers this repository only: the Gameforge Client and its files, including
`frontend.pak`, remain Gameforge's.
