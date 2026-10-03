/*
 * mt2-account-aliases - Gameforge Client add-on
 * ---------------------------------------------
 * Injected into the Gameforge Client UI (resources/frontend.pak -> index.html).
 * It lets a player give readable aliases to Metin2 game accounts whose names are
 * auto-generated ids (e.g. "playerg123456789"), and search the account list by alias.
 *
 * WHERE THE LIST IS: the game account list sits in the Settings window, a popup that the
 * main page opens with window.open("", "popup") and fills through a React portal, from
 * the main page's own script context. So the add-on wraps window.open and decorates every
 * same-origin window it gets back, as well as its own page.
 *
 * SECURITY MODEL (why this is safe to share):
 *   - Runs inside the launcher's own web page, with the same rights as the stock UI.
 *   - Makes NO network request. Grep this file: there is no fetch / XMLHttpRequest /
 *     WebSocket / sendBeacon. It never reads the session token, cookies or account data.
 *   - Reads only the account names already rendered on screen.
 *   - Wraps window.open only to learn which windows the launcher opens; the call itself
 *     goes through unchanged.
 *   - Stores aliases in localStorage (per machine). No server, no database.
 *   - Never adds/removes children inside React-owned nodes: it only sets attributes and
 *     draws its own overlay layer, so it cannot break React's DOM reconciliation.
 *   - Uses no prompt()/alert()/download (unreliable inside CEF): its own inline editor
 *     and a copy/paste JSON panel instead.
 *
 * No remote debugging port is opened. This file is the whole trust surface.
 */
(function () {
  "use strict";

  // ---- pure helpers (also exported for Node unit tests) --------------------

  function normalize(s) {
    return String(s == null ? "" : s).trim().toLowerCase();
  }

  function escapeRegExp(s) {
    return String(s).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  // Accounts whose alias contains the query (the stock search can't see aliases).
  function aliasOriginalsFor(query, entries) {
    var q = normalize(query);
    if (!q) return [];
    var out = [];
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i];
      if (e.alias && normalize(e.alias).indexOf(q) !== -1) out.push(e.original);
    }
    return out;
  }

  // Build the regex the stock search runs on each account id, so a single box
  // matches BOTH the id (substring, like the stock search) and the aliases.
  function buildCombinedFilter(query, aliasOriginals) {
    var q = String(query == null ? "" : query).trim();
    if (!q) return "";
    var parts = [escapeRegExp(q)];
    if (aliasOriginals && aliasOriginals.length) {
      parts.push("^(" + aliasOriginals.map(escapeRegExp).join("|") + ")$");
    }
    return parts.join("|");
  }

  // Under Node (tests) there is no DOM: export the pure helpers and stop here. Test for
  // the DOM rather than for `module`: a page script may well define a global `module`.
  if (typeof window === "undefined" || typeof document === "undefined") {
    if (typeof module !== "undefined" && module.exports) {
      module.exports = {
        normalize: normalize,
        escapeRegExp: escapeRegExp,
        aliasOriginalsFor: aliasOriginalsFor,
        buildCombinedFilter: buildCombinedFilter
      };
    }
    return;
  }

  // ---- diagnostics ---------------------------------------------------------

  // Progress is published in an attribute of the main page's <body>, for every window the
  // add-on follows. It shows nothing by itself: the installer's diagnostic mode adds a CSS
  // label, in the main page only, that displays it (no devtools needed).
  var lastError = "";

  function setState(text) {
    try {
      (document.body || document.documentElement).setAttribute("data-gf-alias-state", text);
    } catch (e) {
      /* nothing to report to */
    }
  }

  function fail(where, err) {
    lastError = "error (" + where + "): " + (err && err.message ? err.message : String(err));
    setState(lastError);
  }

  setState("script loaded");

  // ---- storage -------------------------------------------------------------

  var STORE_KEY = "gfAliasAddon.v1";
  // Name cell of every account row. The launcher reuses this id on each row.
  var NAME_CELL = 'td[id="QA_MenuSettings_GameAccount_Selection"]';
  // Longer aliases are cut on screen (the row must not grow); the tooltip has them whole.
  var SHOWN_ALIAS_MAX = 20;
  // A pencil in the line of the table's own Font Awesome icons (drawn here, not copied).
  var PENCIL_SVG =
    '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M1.5 14.5l1-3.6 2.6 2.6z' +
    'M3.3 10.2l7.2-7.2 2.5 2.5-7.2 7.2zM11.2 2.3l1.2-1.2a1 1 0 0 1 1.4 0l1.1 1.1' +
    'a1 1 0 0 1 0 1.4l-1.2 1.2z"/></svg>';

  // The main page's localStorage, which its popups share (same origin).
  function loadStore() {
    try {
      var raw = window.localStorage.getItem(STORE_KEY);
      var obj = raw ? JSON.parse(raw) : {};
      return obj && typeof obj === "object" ? obj : {};
    } catch (e) {
      return {};
    }
  }

  function saveStore(s) {
    try {
      window.localStorage.setItem(STORE_KEY, JSON.stringify(s));
    } catch (e) {
      /* private mode / disabled storage: aliases just won't persist */
    }
  }

  var store = loadStore();

  function storeEntries() {
    return Object.keys(store).map(function (k) {
      return { original: k, alias: store[k] };
    });
  }

  // ---- styles (attribute-driven; never touches React's child nodes) --------

  function injectStyle(doc) {
    if (doc.getElementById("gf-alias-style")) return;
    // Spacing uses margins, never flex `gap`: the launcher's Chromium 72 ignores it there.
    var css =
      // Room for the pencil at the right of every name cell, so it never covers the text.
      NAME_CELL + "{padding-right:2.25rem !important;}" +
      // Cell with a non-empty alias: hide the real text node and show, on the same line
      // so the row keeps its height, the alias then the original id, small and dimmed.
      NAME_CELL + '[data-gf-alias]:not([data-gf-alias=""]){font-size:0 !important;white-space:nowrap !important;}' +
      NAME_CELL + '[data-gf-alias]:not([data-gf-alias=""])::before{content:attr(data-gf-alias);font-size:.875rem;}' +
      NAME_CELL + '[data-gf-alias]:not([data-gf-alias=""])::after{content:attr(data-gf-orig);font-size:.7rem;color:#8e999f;margin-left:.6em;}' +
      // Pencil overlay layer, styled like the table's icons: blue, 80% until hovered.
      "#gf-alias-pencils{position:fixed;left:0;top:0;width:0;height:0;z-index:2147483646;pointer-events:none;}" +
      ".gf-alias-pencil{position:fixed;transform:translate(-100%,-50%);pointer-events:auto;cursor:pointer;" +
      "color:#00b5fc;opacity:.8;transition:opacity .15s;padding:3px;line-height:0;}" +
      ".gf-alias-pencil:hover{opacity:1;}" +
      ".gf-alias-pencil svg{display:block;width:.9rem;height:.9rem;fill:currentColor;}" +
      // Inline editor.
      ".gf-alias-editor{position:fixed;z-index:2147483647;display:flex;align-items:center;" +
      "background:#0a1827;border:1px solid #00b5fc;border-radius:5px;padding:5px;" +
      "box-shadow:0 6px 18px rgba(0,0,0,.5);font:13px sans-serif;}" +
      ".gf-alias-editor > * + *{margin-left:4px;}" +
      ".gf-alias-editor input{background:#002638;border:1px solid #00496b;color:#fff;border-radius:4px;" +
      "padding:4px 7px;width:170px;outline:none;}" +
      ".gf-alias-editor button{background:#00496b;border:0;color:#fff;border-radius:4px;padding:4px 8px;cursor:pointer;}" +
      ".gf-alias-editor button:hover{background:#00b5fc;}" +
      // Toolbar.
      "#gf-alias-bar{position:fixed;right:14px;bottom:12px;z-index:2147483646;display:flex;" +
      "align-items:center;background:#0a1827;border:1px solid #00496b;border-radius:6px;padding:6px 8px;" +
      "font:13px/1.2 sans-serif;color:#cfe3ef;box-shadow:0 4px 14px rgba(0,0,0,.4);max-width:calc(100vw - 28px);flex-wrap:wrap;}" +
      "#gf-alias-bar input{background:#002638;border:1px solid #00496b;color:#fff;border-radius:4px;" +
      "padding:4px 7px;width:185px;outline:none;}" +
      "#gf-alias-bar button{background:#00496b;border:0;color:#fff;border-radius:4px;padding:4px 8px;cursor:pointer;}" +
      "#gf-alias-bar button:hover{background:#00b5fc;}" +
      "#gf-alias-bar > * + *{margin-left:8px;}" +
      "#gf-alias-bar .gf-tag{color:#00b5fc;font-weight:bold;}" +
      // Manage panel (export/import via copy/paste - no file download needed).
      "#gf-alias-panel{position:fixed;right:14px;bottom:56px;z-index:2147483647;width:320px;max-width:calc(100vw - 28px);" +
      "background:#0a1827;border:1px solid #00496b;border-radius:6px;padding:10px;" +
      "font:13px/1.35 sans-serif;color:#cfe3ef;box-shadow:0 8px 22px rgba(0,0,0,.5);}" +
      "#gf-alias-panel .gf-h{font-size:.78rem;color:#8fb3c6;margin-bottom:6px;}" +
      "#gf-alias-panel textarea{width:100%;height:150px;box-sizing:border-box;background:#002638;border:1px solid #00496b;" +
      "color:#fff;border-radius:4px;padding:6px;font:12px/1.3 monospace;resize:vertical;outline:none;}" +
      "#gf-alias-panel .gf-row{display:flex;align-items:center;margin-top:8px;flex-wrap:wrap;}" +
      "#gf-alias-panel .gf-row > * + *{margin-left:6px;}" +
      "#gf-alias-panel button{background:#00496b;border:0;color:#fff;border-radius:4px;padding:4px 9px;cursor:pointer;}" +
      "#gf-alias-panel button:hover{background:#00b5fc;}" +
      "#gf-alias-panel .gf-msg{color:#59d185;font-size:.78rem;}";
    var el = doc.createElement("style");
    el.id = "gf-alias-style";
    el.textContent = css;
    (doc.head || doc.documentElement).appendChild(el);
  }

  // ---- drive the launcher's own search (keeps its pagination working) ------

  // Set an input's value the way React / the launcher detects it: with the native setter
  // of the input's own window (a popup has its own prototypes).
  function setNativeValue(input, value) {
    var proto = input.ownerDocument.defaultView.HTMLInputElement.prototype;
    var desc = Object.getOwnPropertyDescriptor(proto, "value");
    if (desc && desc.set) desc.set.call(input, value);
    else input.value = value;
  }

  function findTableInput(doc) {
    var cell = doc.querySelector(NAME_CELL);
    var table = cell && cell.closest("table");
    return table ? table.querySelector("thead input") : null;
  }

  // Make the launcher's OWN search box (in the table header) alias-aware, without
  // changing the text the user sees: intercept its input event, hand the launcher a
  // combined id+alias regex, then restore the typed text for display. On any trouble
  // it does nothing, so the native search keeps working by id.
  var searchBusy = false;
  function onNativeInput(e) {
    if (searchBusy) return; // our own synthetic event: let it reach the launcher
    var input = e.currentTarget;
    var typed, combined;
    try {
      typed = input.value;
      combined = buildCombinedFilter(typed, aliasOriginalsFor(typed, storeEntries()));
    } catch (err) {
      return;
    }
    if (combined === typed) return; // nothing to translate: let the raw query through
    e.stopImmediatePropagation();   // stop the raw query from reaching the launcher
    searchBusy = true;
    try {
      setNativeValue(input, combined);
      input.dispatchEvent(new input.ownerDocument.defaultView.Event("input", { bubbles: true }));
      setNativeValue(input, typed); // restore what the user sees
    } finally {
      searchBusy = false;
    }
  }

  function attachNativeSearch(doc) {
    var input = findTableInput(doc);
    if (!input || input.getAttribute("data-gf-search-hooked")) return;
    input.setAttribute("data-gf-search-hooked", "1");
    input.addEventListener("input", onNativeInput, true); // capture, before the launcher
  }

  // ---- row rendering -------------------------------------------------------

  function nameCells(doc) {
    return Array.prototype.slice.call(doc.querySelectorAll(NAME_CELL));
  }

  // Read the original id straight from React's text node (we never change it).
  function originalOf(cell) {
    return (cell.textContent || "").trim();
  }

  function decorateCells(doc) {
    nameCells(doc).forEach(function (cell) {
      var original = originalOf(cell);
      if (!original) return;
      cell.setAttribute("data-gf-orig", original);
      var alias = store[original] || "";
      if (alias) {
        var shown = alias.length > SHOWN_ALIAS_MAX ? alias.slice(0, SHOWN_ALIAS_MAX - 1) + "…" : alias;
        cell.setAttribute("data-gf-alias", shown);
        cell.title = original + "  →  " + alias;
      } else {
        cell.removeAttribute("data-gf-alias");
      }
    });
  }

  function pencilLayer(doc) {
    var layer = doc.getElementById("gf-alias-pencils");
    if (!layer) {
      layer = doc.createElement("div");
      layer.id = "gf-alias-pencils";
      doc.body.appendChild(layer);
    }
    return layer;
  }

  function positionPencils(view) {
    var doc = view.doc;
    var layer = pencilLayer(doc);
    layer.textContent = "";
    nameCells(doc).forEach(function (cell) {
      var original = cell.getAttribute("data-gf-orig") || originalOf(cell);
      if (!original) return;
      var rect = cell.getBoundingClientRect();
      if (rect.width === 0 && rect.height === 0) return; // off-screen
      var pencil = doc.createElement("div");
      pencil.className = "gf-alias-pencil";
      pencil.innerHTML = PENCIL_SVG;
      pencil.title = "Edit the alias of " + original;
      pencil.style.left = rect.right - 8 + "px";
      pencil.style.top = rect.top + rect.height / 2 + "px";
      pencil.addEventListener("click", function (ev) {
        ev.stopPropagation();
        openEditor(view, original, rect);
      });
      layer.appendChild(pencil);
    });
  }

  // ---- inline editor -------------------------------------------------------

  function closeEditor(doc) {
    var b = doc.getElementById("gf-alias-editor");
    if (!b) return;
    if (b._outside) doc.removeEventListener("mousedown", b._outside, true);
    b.parentNode.removeChild(b);
  }

  function openEditor(view, original, rect) {
    var doc = view.doc;
    closeEditor(doc);
    var box = doc.createElement("div");
    box.className = "gf-alias-editor";
    box.id = "gf-alias-editor";

    var input = doc.createElement("input");
    input.type = "text";
    input.maxLength = 64;
    input.value = store[original] || "";
    input.placeholder = "alias for " + original;

    var ok = doc.createElement("button");
    ok.textContent = "OK";
    var cancel = doc.createElement("button");
    cancel.textContent = "✕";

    box.appendChild(input);
    box.appendChild(ok);
    box.appendChild(cancel);
    doc.body.appendChild(box);

    var top = Math.max(8, Math.min(rect.top - 6, view.win.innerHeight - 48));
    var left = Math.max(8, Math.min(rect.right - 220, view.win.innerWidth - 250));
    box.style.top = top + "px";
    box.style.left = left + "px";
    input.focus();
    input.select();

    function close() {
      closeEditor(doc);
    }
    function save() {
      var v = input.value.trim();
      if (v) store[original] = v;
      else delete store[original];
      saveStore(store);
      close();
      refreshAll();
    }
    ok.addEventListener("click", save);
    cancel.addEventListener("click", close);
    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter") save();
      else if (e.key === "Escape") close();
    });
    box._outside = function (e) {
      if (!box.contains(e.target)) close();
    };
    setTimeout(function () {
      doc.addEventListener("mousedown", box._outside, true);
    }, 0);
  }

  // ---- toolbar + manage panel ---------------------------------------------

  function buildBar(doc) {
    if (doc.getElementById("gf-alias-bar")) return;
    var bar = doc.createElement("div");
    bar.id = "gf-alias-bar";

    var tag = doc.createElement("span");
    tag.className = "gf-tag";
    tag.textContent = "Alias";
    tag.title = "The launcher's search also finds accounts by alias.";
    bar.appendChild(tag);

    var manage = doc.createElement("button");
    manage.textContent = "Manage";
    manage.addEventListener("click", function () {
      toggleManager(doc);
    });
    bar.appendChild(manage);

    doc.body.appendChild(bar);
  }

  function closeManager(doc) {
    var p = doc.getElementById("gf-alias-panel");
    if (p) p.parentNode.removeChild(p);
  }

  function toggleManager(doc) {
    if (doc.getElementById("gf-alias-panel")) {
      closeManager(doc);
      return;
    }
    var p = doc.createElement("div");
    p.id = "gf-alias-panel";

    var h = doc.createElement("div");
    h.className = "gf-h";
    h.textContent = "Alias backup (JSON) — Copy to export; paste, then Apply to import.";

    var ta = doc.createElement("textarea");
    ta.spellcheck = false;
    ta.value = JSON.stringify(store, null, 2);

    var row = doc.createElement("div");
    row.className = "gf-row";
    var copy = doc.createElement("button");
    copy.textContent = "Copy";
    var apply = doc.createElement("button");
    apply.textContent = "Apply";
    var close = doc.createElement("button");
    close.textContent = "Close";
    var msg = doc.createElement("span");
    msg.className = "gf-msg";
    row.appendChild(copy);
    row.appendChild(apply);
    row.appendChild(close);
    row.appendChild(msg);

    p.appendChild(h);
    p.appendChild(ta);
    p.appendChild(row);
    doc.body.appendChild(p);

    function selectFallback() {
      ta.focus();
      ta.select();
      msg.textContent = "Selected — press Ctrl+C";
    }
    copy.addEventListener("click", function () {
      try {
        // The focused window's clipboard: the popup's, when the panel is in a popup.
        (doc.defaultView || window).navigator.clipboard.writeText(ta.value).then(function () {
          msg.textContent = "Copied";
        }, selectFallback);
      } catch (e) {
        selectFallback();
      }
    });
    apply.addEventListener("click", function () {
      var obj;
      try {
        obj = JSON.parse(ta.value);
        if (!obj || typeof obj !== "object") throw new Error("bad");
      } catch (e) {
        msg.style.color = "#ff8a8a";
        msg.textContent = "Invalid JSON";
        return;
      }
      Object.keys(store).forEach(function (k) { delete store[k]; });
      Object.keys(obj).forEach(function (k) {
        if (typeof obj[k] === "string" && obj[k].trim()) store[k] = obj[k].trim();
      });
      saveStore(store);
      msg.style.color = "#59d185";
      msg.textContent = "Applied";
      refreshAll();
    });
    close.addEventListener("click", function () {
      closeManager(doc);
    });
  }

  // ---- views: the main page and the popups it opens -------------------------

  // One entry per decorated window: { win, doc, observer, scheduled, count }.
  var views = [];

  // Diagnostic summary of every followed window, published on the main page.
  function publishState() {
    var cells = 0;
    views.forEach(function (v) { cells += v.count; });
    setState((cells ? "active - " + cells + " account(s) on screen" : "active - no account on screen") +
      (views.length > 1 ? " (" + views.length + " windows)" : "") +
      (lastError ? " - " + lastError : ""));
  }

  function refresh(view) {
    if (view.win.closed) return;
    var doc = view.doc;
    // Pause observation while we write our own nodes, otherwise our mutations
    // (rebuilding the pencils) would retrigger the observer every frame.
    view.observer.disconnect();
    try {
      var count = doc.querySelectorAll(NAME_CELL).length;
      if (count) {
        injectStyle(doc);
        decorateCells(doc);
        positionPencils(view);
        attachNativeSearch(doc);
        buildBar(doc);
      } else {
        var layer = doc.getElementById("gf-alias-pencils");
        if (layer) layer.textContent = "";
      }
      view.count = count;
      publishState();
    } catch (err) {
      fail("refresh", err);
    } finally {
      view.observer.observe(doc.documentElement, { childList: true, subtree: true, characterData: true });
    }
  }

  function refreshAll() {
    views.slice().forEach(refresh);
  }

  function schedule(view) {
    if (view.scheduled || view.win.closed) return;
    view.scheduled = true;
    view.win.requestAnimationFrame(function () {
      view.scheduled = false;
      refresh(view);
    });
  }

  // Starts decorating a window (the main page or a popup). Safe to call again.
  function attach(win) {
    var doc = win.document; // throws on a cross-origin window: callers skip those
    for (var i = 0; i < views.length; i++) {
      if (views[i].win !== win) continue;
      if (views[i].doc === doc) return;
      views.splice(i, 1); // the window has loaded a new document
      break;
    }
    var view = { win: win, doc: doc, observer: null, scheduled: false, count: 0 };
    // The window's own MutationObserver: it observes nodes of its own document.
    view.observer = new win.MutationObserver(function () {
      schedule(view);
    });
    win.addEventListener("scroll", function () { schedule(view); }, true);
    win.addEventListener("resize", function () { schedule(view); });
    views.push(view);
    refresh(view); // connects the observer in its finally block
  }

  // The launcher opens the Settings window (account list) itself and fills it from this
  // script context: catch every window it opens. Installed right away, before the
  // launcher's own scripts run (they are deferred; this one sits at the end of <body>).
  try {
    var nativeOpen = window.open;
    window.open = function () {
      var win = nativeOpen.apply(this || window, arguments);
      try {
        if (win) attach(win);
      } catch (err) {
        /* cross-origin or already closed window: nothing to decorate */
      }
      return win;
    };
  } catch (err) {
    fail("window.open", err);
  }

  // ---- lifecycle -----------------------------------------------------------

  function forget(view) {
    var i = views.indexOf(view);
    if (i !== -1) views.splice(i, 1);
    publishState();
  }

  // Safety net, in case mutations or animation frames never reach us in this host. It
  // also forgets closed popups and follows windows that load a new document.
  function sweep() {
    views.slice().forEach(function (view) {
      try {
        if (view.win.closed) {
          forget(view);
        } else if (view.win.document !== view.doc) {
          attach(view.win);
        } else if (view.doc.querySelector(NAME_CELL) && !view.doc.getElementById("gf-alias-bar")) {
          view.scheduled = false;
          refresh(view);
        }
      } catch (err) {
        forget(view);
      }
    });
  }

  function start() {
    try {
      // In the main <head> early, so the popups' style mirroring copies it.
      injectStyle(document);
      attach(window);
      window.setInterval(sweep, 1500);
    } catch (err) {
      fail("start", err);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();
