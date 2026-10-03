# mt2-account-aliases

An add-on for the **Gameforge Client** (the launcher) that gives readable names to Metin2 game
accounts. The launcher names the accounts it creates with generated ids such as
`playerg123456789`; with dozens of them listed four per page, telling them apart is guesswork.
The add-on attaches an alias to each account and finds an account by its alias, inside the
launcher's own account list.

**Status:** works with Gameforge Client 2.8.5.1959 (interface 0.486.2), checked on 2026-10-03; no
release yet. Unofficial: not affiliated with or endorsed by Gameforge. It modifies one launcher
file and never touches the game client; use it at your own risk.

Read [CLAUDE.md](CLAUDE.md) before changing anything: frozen decisions, verified facts about the
launcher, hard rules and known traps.

## What it does

In **Settings > Game account**:

- a pencil next to each account name opens a small editor: Enter saves, Escape or a click outside
  cancels, an empty alias removes it;
- an account with an alias shows the alias followed by its id in small grey type; aliases longer
  than 20 characters are cut on screen and shown whole in the tooltip;
- the launcher's own search (the magnifier above the table) also finds accounts by alias, and its
  pagination keeps working;
- the **Manage** button, bottom right, lists every alias as JSON: copy it to keep a backup, paste
  it and press **Apply** to restore it or to move the aliases to another PC.

Aliases are stored by the launcher's embedded browser (`localStorage`), on this PC only. They
survive reinstalling the add-on; anything that clears the launcher's web data would lose them, so
keep a JSON backup.

## How it works

The launcher's interface is a web app packed in `resources\frontend.pak`, a plain ZIP. The
installer backs that file up, then inlines [`src/alias-addon.js`](src/alias-addon.js) as a
`<script>` at the end of its `index.html`. The Settings window is a popup that the main page opens
and fills by itself, so the add-on intercepts `window.open` to reach it.

The add-on makes **no network request**, never reads the session token, cookies or account data,
reads only the account names already on screen, and only adds attributes and its own overlay to
the page. That one file is the whole trust surface.

## Install

Requirements: Windows 10 or 11, the Gameforge Client and administrator rights. `frontend.pak`
sits under `Program Files`, so installing and uninstalling ask for elevation (a UAC prompt).

1. Download the archive of the [latest release](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
   and extract it.
2. Close your Metin2 clients, then **close the launcher completely**, including its
   notification-area icon.
3. Double-click `Install.cmd`. `Uninstall.cmd` restores the original `frontend.pak` byte for
   byte, and `Status.cmd` reports what is installed without changing anything.

The archive's `README.txt` is the players' guide. The `.cmd` files only start the installer,
`scripts/alias-addon.ps1`, with Windows PowerShell 5.1 and `-ExecutionPolicy Bypass`; extra
arguments go through (`Install.cmd -Diagnostic`).

### From a clone

The same `.cmd` files are in [`release/`](release/), or call the installer directly, with Windows
PowerShell 5.1 or PowerShell 7:

```powershell
.\scripts\alias-addon.ps1 status    # changes nothing: what is installed, backup state
.\scripts\alias-addon.ps1 install   # installs, or updates after an edit of src/alias-addon.js
.\scripts\alias-addon.ps1 revert    # restores the original frontend.pak byte for byte
```

If script execution is blocked on the machine, run
`powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\alias-addon.ps1 install`.

`install` keeps the untouched original next to it as `frontend.pak.alias-backup`, writes the
patched file aside, checks that every other file in the archive is unchanged, then swaps it in
one step. `-PakPath` points the script at another copy of `frontend.pak`, and `-AddonPath` at
another add-on file; both are how it is tested.

### When the launcher updates its interface

The launcher patches `frontend.pak` with binary deltas (xdelta3), which cannot apply to a modified
file. When it announces an interface update, or reports that it could not apply one:

1. close the launcher and run `revert` (`Uninstall.cmd`);
2. start the launcher, let it update, then close it;
3. run `install` (`Install.cmd`) again.

`status` reports a backup that no longer matches the current file, which is what a launcher
update leaves behind; `install` then replaces it with a fresh one.

### Troubleshooting

`install -Diagnostic` adds a small label at the bottom left of the launcher's main window, saying
how far the add-on got in every window it follows:

| Label | Meaning |
| --- | --- |
| none at all | the launcher did not display the patched `index.html` |
| red, `script did not run` | the patched page is displayed, but its script never ran |
| `active - no account on screen`, with the account list open | the script runs but finds no account cell |
| `active - 4 account(s) on screen (2 windows)` | the account list is found and decorated |
| `... error (...): ...` | the message says what failed |

`install` without the switch removes the label.

If the launcher's interface changes language after you log in again, the add-on has nothing to do
with it: the globe icon at the top right of the launcher sets it back.

## Layout

| Path | Content |
| --- | --- |
| [`src/alias-addon.js`](src/alias-addon.js) | the add-on, the only code that runs inside the launcher |
| [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1) | the installer: `status`, `install`, `revert`, `-Diagnostic` |
| [`test/logic.test.cjs`](test/logic.test.cjs) | unit tests of the add-on's pure helpers, for Node |
| [`test/mock-launcher.html`](test/mock-launcher.html) | look-alike of the launcher's Settings popup, to run the add-on in a browser |
| [`release/`](release/) | what the players' archive adds (`.cmd` files, `README.txt`) and `build.py`, which builds it |
| [`.github/workflows/release.yml`](.github/workflows/release.yml) | builds the archive on GitHub and opens a draft release |
| [`docs/`](docs/) | how the launcher works, as far as the add-on is concerned |
| [`CLAUDE.md`](CLAUDE.md) | context, frozen decisions, rules and traps: read it first |
| [`CHANGELOG.md`](CHANGELOG.md) | what changed, and why |
| [`LICENSE`](LICENSE) | the MIT licence |

## Tests

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

## Releasing

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

## Licence

[MIT](LICENSE). It covers this repository only: the Gameforge Client and its files, including
`frontend.pak`, remain Gameforge's.
