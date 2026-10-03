# How the Gameforge Client works, as seen from the alias add-on

Surveyed on 2026-10-03 on Gameforge Client 2.8.5.1959 (`master@eda2b413`), CEF 3.3626.1895
(Chromium 72), interface 0.486.2 (`FrontendVersion`). Everything was established read-only (static
code of the pak, strings of the binaries, registry), without developer tools or a debugging port,
and without reading the launcher's session data. This document covers only what the add-on needs.

The webpack module ids and bundle names quoted here change with every interface version. After an
update, search by stable strings (`QA_MenuSettings_…`, `createPopup`, `mirrorStyles`,
`useDataTable`), not by module number or offset.

## The interface: `frontend.pak`

- File `C:\Program Files (x86)\GameforgeClient\resources\frontend.pak`, a standard, unsigned ZIP.
  The CEF layer built into `gfclient.exe` serves it on `spark://www.gameforge.com/`.
- 79 entries, all deflated, UTF-8 names (bit 11), no encryption, data descriptor, extra field or
  comment; "version made by" Unix. One entry is empty but deflated (`js/css.31d6cfe0.js`, 2 bytes
  `03 00`): it is the one .NET Framework damages (see below).
- sha256 of the original (interface 0.486.2):
  `9fa38e9fe7d36704e0a3dc54f781ee1f1ea04f58fcefcbc1cdd25df68b2f7971`, 4,214,626 bytes.
- Permissions: `resources\` gives Users read-only access; only SYSTEM, Administrators and
  TrustedInstaller can write. Hence the installer's UAC elevation.
- `index.html` (1,424 bytes, a single line): Pixelzirkus' `pz.js` loaded synchronously from
  `https://pixelzirkus.gameforge.com`, two inline Google Tag Manager scripts
  (`data-cookieconsent="ignore"`), the bundles `js/vendors.a37bd54f.js` and `js/app.31f63ecf.js`
  as `defer`, `<base href="/">`, `<meta charset="utf-8">` at byte 1016, then
  `<body><div id="root"></div></body>`.

## Interface updates

The `FrontendUpdater` module of `gfclient.exe` ("Starting frontend update") downloads a delta
(`temp.pak`), runs `xdelta3 -f -d -s frontend.pak <delta> frontend.pak.update`, then replaces the
file ("Successfully applied new frontend. Cleaning up."). On failure: "Could not apply new
frontend version." and `xdelta_failed`. A modified pak makes the patch fail, hence the revert,
update, install procedure. The current version is in
`HKLM\SOFTWARE\WOW6432Node\Gameforge4d\GameforgeClient\MainApp\FrontendVersion`.

## What runs in the page

- No CSP: neither `Content-Security-Policy` nor `script-src` in `gfclient.exe` or
  `SparkWebHelper.exe`, in ASCII or UTF-16. No service worker in the bundles.
- `pz.js` is an IIFE (`(function pz(win,doc,undefined){…})`): it creates no global `module`.
  The add-on tells that it runs in a page by `window`, not by the absence of `module`.

## The Settings window is a popup

Module 54705 of `vendors.a37bd54f.js` exports popup utilities:

- `createPopup(opts)`: `window.open("", "popup", "width=…,height=…,toolbar=…,status=…")`;
- `mirrorStyles(source, target)`: clones `head > style, head > meta, head > link` from the main
  document into the popup and waits for the stylesheets to load;
- `createElement`: creates an element of the main document and sets its attributes.

The "popup modal" component (same bundle, around offset 1,060,000) uses them when it opens: it
dims the main window, opens the popup, puts a temporary style
`#root { opacity: 0; overflow: hidden; }` and a `<base href=origin>` in it, copies the styles,
appends `<div id="root">`, then renders the modal into that `#root` with `createPortal`. The JSS
styles are injected into the popup's `<head>` (`insertionPoint`) and ReactModal attaches to it
(`parentSelector` pointing at the popup's `<body>`). On close: `close()`; on `beforeunload`, the
callback, then the end of the dimming.

All of this code runs in the JavaScript context of the main window. The popup's document is
therefore not `index.html`, and a script that only looks at its own page sees nothing there. On
the other hand, since that script shares the application's context, it can get hold of the popup
by wrapping `window.open` before the bundles start. That is what the add-on does.

Diagnostic mode is what showed it: the label read "active - no account on screen" in the main
window, and nothing at all in the Settings window.

## The account table

- Rendered in `app.31f63ecf.js` with `Br.DataTable` (`pageSize: 4`, paginated); columns: action
  icons, name, last login.
- `DataTable` (module 64643 of `vendors`) = the components of the base `Table` (module 2867, which
  re-exports 82699) overridden by module 98220 (`Body`, `Cell`, `FilterBar`, `HeaderCell`, `Row`).
  `DataTable`'s `Cell` (module 24674) strips `children`, `idx` and `value`, and hands everything
  else to `Table.Cell`, which is `createElement("td", props)`. So the `id` does reach the `<td>`.
- Name cell:
  `DataTable.Cell { id: "QA_MenuSettings_GameAccount_Selection", value: displayName, className: displayNameCell, onClick }`,
  with the same `id` on every row. Play icon: `QA_MenuSettings_GameAccount_Start`; the cog icon
  (`faCog`) only shows when the account has a `legacyAccountLink`.
- Filter (`filterRows`): `new RegExp(filterValue, "i")` tested against the `props.value` of each
  cell; a row passes when one of its cells matches. Sorting compares
  `children[column].props.value`, then the list is sliced into pages. The magnifier shows the
  field in the table header (`thead input`).
- The table's JSS styles: background `#0a1827`, font `0.875rem`, rows `#002638` (hover and
  selection `#00496b`), cells `padding: .5rem 1rem`, SVG icons `#00b5fc`, `1rem`, opacity 0.8 (1 on
  hover); name cell `max-width: 10rem; overflow: hidden; text-overflow: ellipsis`; last login in
  italics, `#8e999f`.
- The popup has a fixed size: a taller row (an alias on two lines) brings up a scrollbar. Hence
  the alias and the id on a single line, and the alias cut at 20 characters.

## The interface language

- The language is part of the route (`/en-GB/library/…`). The i18n module of `app.31f63ecf.js`
  defaults to `"en-GB"` and uses the storage key `"locale"`.
- The choice is reported to the client (`setClientLocale`), which stores it in
  `HKCU\SOFTWARE\Gameforge4d\GameforgeClient\MainApp\Locale`.
- The selector (`LocaleSelector`) sits behind the globe icon, at the top right.
- The interface can switch language after logging out and back in. The add-on has no part in it;
  the globe sets it back.

## Tooling traps

- **.NET Framework, `ZipArchive` in Update mode**: when it rewrites the archive, it turns the empty
  deflated entry into "stored" while keeping its 2 compressed bytes. The entry becomes
  inconsistent and .NET reads it back as 2 bytes of content. .NET (Core) writes it correctly, as a
  0-byte "stored" entry. The installer's check caught it; the installer now rewrites the ZIP byte
  for byte and rebuilds only the `index.html` entry.
- **Windows PowerShell 5.1**: `$PSScriptRoot` is empty in parameter default values under `-File`.
  A `.ps1` without a BOM is read as ANSI, hence ASCII-only messages. `[IO.File]::Replace` takes
  `[NullString]::Value`, not `$null`.
- **Chromium 72**: `gap` is ignored in a flex container (support arrived with Chrome 84); spacing
  uses margins.
- **Headless Chrome**: `--dump-dom` captures right after load, before a self-test's timers, and
  Chrome does not exit by itself while a popup is open. The self-test result therefore goes
  through a `/__result?…` request read from the local server's log. A deep `--user-data-dir`
  exceeds `MAX_PATH`.
- **Git Bash's `tar`**: it is GNU tar, which cannot read ZIP files. Use
  `C:\Windows\System32\tar.exe` (bsdtar).
