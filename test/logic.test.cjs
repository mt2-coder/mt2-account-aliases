/* Unit tests for the pure helpers of the add-on. Run: node test/logic.test.cjs */
"use strict";
const assert = require("assert");
const a = require("../src/alias-addon.js");

let passed = 0;
function ok(name, cond) {
  assert.ok(cond, name);
  passed++;
}

// normalize
ok("normalize trims + lowercases", a.normalize("  Meley DPS ") === "meley dps");
ok("normalize handles null", a.normalize(null) === "");

// escapeRegExp
ok("escape keeps plain text", a.escapeRegExp("playerg1") === "playerg1");
ok("escape protects dots", a.escapeRegExp("a.b") === "a\\.b");

// aliasOriginalsFor
const entries = [
  { original: "playerg123456789", alias: "Meley Warrior" },
  { original: "playerg987654321", alias: "Sura Balathor" },
  { original: "playergf", alias: "Main character" }
];
ok("empty query -> no alias matches", a.aliasOriginalsFor("  ", entries).length === 0);
assert.deepStrictEqual(a.aliasOriginalsFor("meley", entries), ["playerg123456789"]);
passed++;
ok("alias match is case-insensitive", a.aliasOriginalsFor("BALA", entries)[0] === "playerg987654321");
ok("no alias match -> empty", a.aliasOriginalsFor("zzz", entries).length === 0);

// buildCombinedFilter
ok("empty query -> '' (clear)", a.buildCombinedFilter("  ", []) === "");
ok("name-only query -> substring", a.buildCombinedFilter("playergf", []) === "playergf");
ok("adds anchored alias ids", a.buildCombinedFilter("meley", ["playerg123456789"]) === "meley|^(playerg123456789)$");

// end to end: one box, the stock regex must find the account by its ALIAS...
(function () {
  const q = "meley";
  const rx = new RegExp(a.buildCombinedFilter(q, a.aliasOriginalsFor(q, entries)), "i");
  ok("alias query matches the aliased id", rx.test("playerg123456789"));
  ok("alias query rejects others", !rx.test("playerg987654321"));
})();
// ...and still find accounts by a partial id, like the stock search.
(function () {
  const q = "playerg9";
  const rx = new RegExp(a.buildCombinedFilter(q, a.aliasOriginalsFor(q, entries)), "i");
  ok("id substring still matches", rx.test("playerg987654321"));
  ok("id substring rejects non-matching", !rx.test("playergf"));
})();

console.log("OK - " + passed + " assertions passed");
