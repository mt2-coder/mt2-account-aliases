# mt2-account-aliases

Add-on for the Gameforge Client (the launcher) that gives readable aliases to Metin2 game
accounts. A game account can never be renamed, and on the Tigerghost server the launcher names
them with generated ids such as `playerg123456789`; it lists them four per page in Settings > Game
account, so a player with dozens of accounts cannot tell them apart. The add-on attaches an alias
to each account and finds an account by its alias. Fully local: no server, no database.

**English is the base language of everything**: code, comments, documentation (`docs/`
included), the add-on's interface, the installer's messages, examples and test data. Other
languages only come as translations of the English text, and English stays the default and
prevails; so far, only the README is translated (see README below). Commits follow Conventional
Commits; `CHANGELOG.md` follows Keep a Changelog and is updated with every change.

Line endings are LF in every checkout (`.gitattributes`): `status` compares the add-on's sha256
with the one recorded in the launcher, and Git for Windows' default `core.autocrlf=true` would make
an unchanged add-on look modified.

Verified against Gameforge Client 2.8.5.1959 (`master@eda2b413`), CEF 3.3626.1895 (Chromium 72),
interface 0.486.2 (bundles `app.31f63ecf.js` and `vendors.a37bd54f.js`), on 2026-10-03. How the
launcher works, in detail: [docs/launcher-internals.md](docs/launcher-internals.md).

## Architecture — frozen decisions

- **Injection point.** `resources\frontend.pak` is a plain, unsigned ZIP that the launcher serves
  on `spark://www.gameforge.com/index.html`. The installer inlines the add-on as
  `<script id="gf-alias-addon" data-cookieconsent="ignore">` right before `</body>`, between
  `<!--gf-alias-addon:begin v=1 addon=<sha256> orig=<sha256>-->` and `<!--gf-alias-addon:end-->`
  (`orig` is the hash of the untouched pak). Cutting that block gives back the original
  `index.html` byte for byte. Inline rather than a separate file because `index.html` already
  runs inline scripts and nothing sets a CSP, while a new file would depend on how the scheme
  handler serves unknown entries.
- **The account list is in a popup.** Settings is a "popup modal" of Gameforge's UI library: the
  main page calls `window.open("", "popup", features)`, copies its `head > style, meta, link` into
  it (`mirrorStyles`), appends `<div id="root">`, and React renders the modal there through a
  portal, from the main page's script context; closing calls `close()`. So the add-on wraps
  `window.open` as soon as it runs, before the deferred bundles, and decorates every same-origin
  window it gets back. A "view" is a window, its document and that window's own
  `MutationObserver`. The add-on's style, injected early into the main `<head>`, is mirrored into
  the popup with the others.
- **Never write into React-owned nodes.** The add-on only sets attributes on the name cells and
  draws its own layers (pencils, editor, toolbar, panel) as children of `<body>`. The alias is
  shown in CSS: `font-size:0` on the cell, alias in `::before`, id in `::after`.
- **Rows never grow.** The popup has a fixed size, and a two-line alias made it scroll. Alias and
  id share one line (`white-space:nowrap`), the alias is cut at 20 characters on screen
  (`SHOWN_ALIAS_MAX`, full text in the tooltip), and every name cell reserves
  `padding-right:2.25rem` so the pencil never covers text.
- **Search by alias drives the native search.** The launcher filters rows with
  `new RegExp(query, "i")` against each cell's `value`. The add-on catches the input event on the
  table's own search box (capture phase), hands the launcher `<escaped query>|^(<id>|<id>)$`, then
  puts the typed text back, through the native setter and `Event` of the input's own window (the
  popup has its own prototypes).
- **Look.** The pencil is a hand-drawn SVG styled like the table's Font Awesome icons (`#00b5fc`,
  opacity .8, full on hover), never a copied icon. Spacing uses margins: see Chromium 72 below.
- **Storage.** `localStorage` key `gfAliasAddon.v1` of the main page, `{ "<id>": "<alias>" }`,
  shared with its popups (same origin). Export and import go through a copy/paste JSON panel: no
  `prompt`, `alert` or download, which are unreliable in CEF.
- **Installer.** `scripts/alias-addon.ps1` backs the pak up next to itself (checked by sha256),
  writes the patched file aside, verifies it (every other entry's content unchanged), then swaps it
  with `File.Replace`. The archive is rewritten **byte for byte**: only `index.html`'s local record
  is rebuilt (deflate, its own CRC-32) and the later offsets shifted. `System.IO.Compression`'s
  Update mode is banned: on .NET Framework it corrupts the empty deflated entry this pak contains
  (`js/css.31d6cfe0.js`). It relaunches itself through UAC when it cannot write, relaying the
  output through a temporary log, and refuses while a launcher started from that installation is
  running. The relaunch passes `-ExecutionPolicy Bypass`: the elevated session does not inherit
  the caller's policy, and Windows PowerShell's default one (Restricted) refuses every script.
- **README.** Written for players first: title, the demo video, what the add-on
  does, why it is safe, install, uninstall, troubleshooting. The technical part comes last, under
  "For developers and Gameforge's teams", including how the feature could be built into the
  launcher. Safety claims there stay strictly true: no claim about what the game or its anti-cheat
  can detect. The video plays in the README from a GitHub upload (`user-attachments`), because
  GitHub strips YouTube players and YouTube's thumbnail URLs change with the thumbnail; the
  YouTube copy (<https://www.youtube.com/watch?v=24Nq1rZX88w>, on the project's own channel) is
  linked right below it.
- **Badges.** Under the language line, the same four in every README: latest release and licence
  (shields.io, read from GitHub), Tests (`tests.yml`'s own badge) and a static "provenance:
  attested" that links to the attestations. Only badges that link to their proof: never "safe",
  "undetected", "no ban" or "virus-free", and no VirusTotal badge (a false positive on an
  elevating PowerShell script would show red, and in Metin2's community it marks cheats and bots).
- **README translations.** One file per language, `README.<code>.md` (`de`, `es`, `fr`, `it`,
  `pt`, `ro`, `tr`), linked from a language line under every README's title. A translation covers the player part
  only and ends with a link to the English technical part; it gives the date of the English text
  it translates and says that the English text prevails. Menus are named with the launcher's own
  labels in that language (in its locale chunks, e.g. German "Einstellungen > Spielaccount") and
  with the launcher's register: `vous` in French, the familiar form elsewhere. Portuguese is
  European, with the Brazilian launcher's labels given next to them. The add-on's buttons and the
  installer's messages stay in English and are quoted as such. A change
  to the player part of `README.md` is carried into every translation, with its date, in the same
  commit. Safety claims never say more than the English ones. `release/README.txt` stays English
  and links to the translations, as do the release notes.
- **Distribution.** Players get a GitHub release, not a clone: a ZIP with `Install.cmd`,
  `Uninstall.cmd`, `Status.cmd`, `README.txt`, `LICENSE`, `scripts/alias-addon.ps1` and
  `src/alias-addon.js`, in the repository's layout so the installer finds the add-on as in a
  clone. The `.cmd` files start `%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe`
  with `-ExecutionPolicy Bypass` (players never open a terminal) and find the script in the
  archive or, from `release/`, in a clone. `release/build.py` builds the ZIP; the
  `.github/workflows/release.yml` workflow, started by hand on `main`, runs it on GitHub, attests
  the archive's provenance and opens a **draft** release whose tag is only created when the draft
  is published. The notes open with a line linking to every README translation (`TRANSLATIONS`
  in `build.py`, which refuses to build when that list, the `README.<code>.md` files and the links
  in `README.txt` disagree); the rest stays in English. Built on GitHub rather than on a PC, so no local file (`CLAUDE.local.md`, a pak
  copy) can slip in. No code signing: a certificate costs money and ties the project to a
  verified legal identity; the files stay plain text that anyone can read.
- **Diagnostics without devtools.** The add-on publishes its state, summed over all its windows,
  in `body[data-gf-alias-state]` of the main page. `install -Diagnostic` adds a CSS-only label,
  in the main window only, that displays it, so it shows even when the script never runs. This is
  how the popup was found.

## Hard rules

A Gameforge account carries every game account of its player: nothing here may put it at risk.

- Nothing touches `metin2client.exe`, its files or its anti-cheat. Only the launcher's interface
  package is modified, and only by the installer.
- Never relaunch the launcher while Metin2 clients run: they are its children. Never start
  `gfclient.exe` with devtools, a remote debugging port or extra arguments: they would expose the
  logged-in session.
- The add-on makes no network request, never calls Gameforge's APIs (some rename the real accounts
  on Gameforge's servers; aliases stay local) and never reads the session token, cookies or
  account data.
- Document only what the add-on needs. How to open the launcher to debugging tools or reach its
  native interfaces stays out of this repository: it would help whoever wants to steal a session.

## Privacy

- Never read or print `browser.log`, `webcache\` (cookies, Local Storage, caches) or anything else
  under `%LOCALAPPDATA%\Gameforge4d\GameforgeClient\`: they hold session data. Work from the static
  code inside the pak instead.
- Never print the command line of `gfclient.exe`: it may carry a session token. With CIM, select
  the properties you need, and filter test browsers by their `--user-data-dir`.
- In the registry, list value names; only print values that are plainly settings, such as
  `Locale` or `FrontendVersion`.
- Nothing personal is committed: no real account names (examples and tests use `playerg…` ids),
  no names of players or contributors, no data taken from a real launcher.

## Launcher facts — verified 2026-10-03

Details, minified module ids and how each fact was found: [docs/launcher-internals.md](docs/launcher-internals.md).

- Installed by default in `C:\Program Files (x86)\GameforgeClient\`, but a player can choose
  another folder. Its Inno Setup installer records the folder as `InstallLocation` of the
  uninstall entry `{d3b2a0c1-f0d0-4888-ae0b-1c5e1febdafb}_is1` (`DisplayName` `Gameforge Client`),
  and the `GameforgeClientService` service runs `gfservice.exe` from it. The installer looks there,
  in that order, then in the default folders, and otherwise asks for `-PakPath`. Each source was
  checked alone; an install outside the default folder was not. `resources\` gives Users
  read-only access, so writing needs elevation. The service runs permanently.
- `frontend.pak`: 79 entries, all deflate, UTF-8 names, no encryption, data descriptor, extra field
  or comment. `index.html` is a single minified line (1,424 bytes): the remote Pixelzirkus
  `pz.js` (synchronous), two inline Google Tag Manager scripts, the deferred `vendors` and `app`
  bundles, `<base href="/">`, `<div id="root">`.
- Interface updates: `FrontendUpdater` (in `gfclient.exe`) downloads a delta (`temp.pak`), runs
  `xdelta3 -f -d -s frontend.pak <delta> frontend.pak.update`, then swaps the files. A modified pak
  makes that patch fail. Current version:
  `HKLM\SOFTWARE\WOW6432Node\Gameforge4d\GameforgeClient\MainApp\FrontendVersion`.
- No CSP (no such string in `gfclient.exe` or `SparkWebHelper.exe`, ASCII or UTF-16) and no
  service worker.
- Account table: `Br.DataTable` with `pageSize: 4`. The name cell is a `DataTable.Cell` with
  `id="QA_MenuSettings_GameAccount_Selection"` (repeated on every row) and `value=displayName`; its
  props reach the `<td>` (`Table.Cell` is `createElement("td", props)`). Launcher styles: table
  font `.875rem`, rows `#002638` (hover `#00496b`), cells `padding:.5rem 1rem`, icons `#00b5fc` at
  opacity .8, secondary text `#8e999f` italic, name cell `max-width:10rem` with
  `overflow:hidden; text-overflow:ellipsis`.
- Interface language: it lives in the route (`/en-GB/…`) and the client keeps the last choice in
  `HKCU\SOFTWARE\Gameforge4d\GameforgeClient\MainApp\Locale`. It can change after logging out
  and back in; the add-on has no part in it, and the globe icon at the top right sets it back.

## Constraints

- **Chromium 72 runs the add-on.** Stay with ES5 plus `closest`, `MutationObserver` and the `Event`
  constructor. No flex `gap` (it arrived in Chrome 84; it is why "Alias" once stuck to "Manage"),
  nothing recent in CSS or JS. A check in a current Chrome does not cover that.
- The add-on is inlined as is: it must never contain `</script` or `<!--` (the installer refuses).
- `scripts/alias-addon.ps1` must keep running on **Windows PowerShell 5.1**: ASCII only (5.1 reads
  a file without BOM as ANSI), no ternary or `??`, no `$PSScriptRoot` in parameter defaults (empty
  under `-File`), `[NullString]::Value` to hand a null string to .NET. In a double-quoted string,
  `"$pak:"` is a parse error (a drive-qualified variable): write `"${pak}:"`. Check paths before
  using them, so that errors come in the installer's English rather than in the system's
  language.
- The `.cmd` files and `release/README.txt` are ASCII. `.gitattributes` checks the `.cmd` files
  out with CRLF, which cmd.exe needs, and `release/build.py` writes both with CRLF whatever the
  checkout did.

## Testing

1. `node test/logic.test.cjs`: the pure helpers. `.github/workflows/tests.yml` also runs it on
   GitHub, on every push to `main` and every pull request.
2. Popup self-test, headless. Serve the repository root with
   `python -m http.server 18770 --bind 127.0.0.1`, capturing its stderr, then start Chrome with
   `--headless=new --disable-popup-blocking --user-data-dir=<short path under %TEMP%>` and
   `--host-resolver-rules="MAP * ~NOTFOUND, EXCLUDE localhost, EXCLUDE 127.0.0.1"` on
   `http://127.0.0.1:18770/test/mock-launcher.html?auto`. The page requests `/__result?<json>`:
   read it in the server log, then stop that Chrome by its `--user-data-dir`, since it never exits
   by itself. `--dump-dom` cannot be used: it captures right after load, before the self-test runs.
   Keep the `--user-data-dir` short: a deep one exceeds `MAX_PATH`.
3. Installer, on copies only (`-PakPath`); a pristine copy is `frontend.pak.alias-backup` while the
   add-on is installed. Cover install, idempotence, update, byte-exact revert, a pak replaced by a
   launcher update, revert without backup, tampered injected code, a refused add-on and
   `-Diagnostic`, under both PowerShells. Validate a patched pak independently: Python `zipfile`
   (`testzip()`, raw compressed bytes unchanged except `index.html`) and Windows' `tar.exe -tf`
   (Git Bash's GNU tar cannot read a ZIP). These scenarios are not automated in the repository
   yet. The elevated relaunch can be checked without UAC: start its exact command line with
   `PSExecutionPolicyPreference` cleared, and, from PowerShell 7, with the machine's
   `PSModulePath` (pwsh's own module paths make Windows PowerShell lose `Get-FileHash`).
4. Release archive: `python release/build.py <version> <dir>`, extract it, mark the files as
   downloaded (`Zone.Identifier` stream, `ZoneId=3`), then run `Status.cmd`, and `Install.cmd` /
   `Uninstall.cmd` with `-PakPath <copy>`, from the extracted folder.
5. The real launcher last: closed, with someone at the machine to accept the UAC prompt.

## Open decisions

- Interface updates stay manual (revert, update, install). Automating them would need a watcher or
  a scheduled task.
