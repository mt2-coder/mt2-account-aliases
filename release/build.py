"""Builds the player archive of a release.

    python release/build.py <version> <output directory>

Writes mt2-account-aliases-<version>.zip, its .sha256 file and release-notes.md (the text of the
draft release) into the output directory. The version must have its own section in CHANGELOG.md.
"""
import hashlib
import os
import pathlib
import re
import subprocess
import sys
import zipfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
REPOSITORY = "mt2-coder/mt2-account-aliases"

# Archive path -> repository path. Nothing else goes into the archive.
FILES = [
    ("Install.cmd", "release/Install.cmd"),
    ("Uninstall.cmd", "release/Uninstall.cmd"),
    ("Status.cmd", "release/Status.cmd"),
    ("README.txt", "release/README.txt"),
    ("LICENSE", "LICENSE"),
    ("scripts/alias-addon.ps1", "scripts/alias-addon.ps1"),
    ("src/alias-addon.js", "src/alias-addon.js"),
]
# Read by cmd.exe or opened in Notepad: ASCII with CRLF, whatever the checkout did. The add-on
# and the installer keep their exact bytes: the installer compares the add-on's sha256.
WINDOWS_TEXT = {"Install.cmd", "Uninstall.cmd", "Status.cmd", "README.txt", "LICENSE"}

# README translations, linked from the top of the release notes: (code, name in that language).
# Every README.<code>.md is listed here, and release/README.txt links to each of them.
TRANSLATIONS = [
    ("de", "Deutsch"),
    ("es", "Español"),
    ("fr", "Français"),
    ("it", "Italiano"),
    ("pt", "Português"),
    ("ro", "Română"),
    ("tr", "Türkçe"),
]

NOTES = """**Install guide in your language:** {translations}

## What's in this version

{changes}

## Install

1. Download `{name}.zip` below and extract it.
2. Close Metin2 and the Gameforge Client, including its icon in the notification area.
3. Double-click `Install.cmd`. If Windows asks, click **Run**, then **Yes**.

`README.txt`, in the archive, covers uninstalling, launcher updates and backing up your aliases.

## Verify the archive

- SHA-256: `{digest}`
- Built by GitHub Actions from commit {commit}. Check its provenance with
  `gh attestation verify {name}.zip --repo {repository}`.
"""


def fail(message):
    sys.exit("build.py: " + message)


def changelog_section(version):
    text = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
    match = re.search(
        r"^## \[" + re.escape(version) + r"\] - \d{4}-\d{2}-\d{2}\n(.*?)(?=^## |^\[|\Z)",
        text,
        re.M | re.S,
    )
    if not match or not match.group(1).strip():
        fail("CHANGELOG.md has no '## [%s] - <date>' section with entries" % version)
    return match.group(1).strip()


def translation_url(code):
    return "https://github.com/%s/blob/main/README.%s.md" % (REPOSITORY, code)


def translations_line():
    listed = sorted(code for code, _ in TRANSLATIONS)
    on_disk = sorted(p.name[len("README."):-len(".md")] for p in ROOT.glob("README.*.md"))
    if listed != on_disk:
        fail("TRANSLATIONS lists %s, but the README translations are %s" % (listed, on_disk))
    guide = (ROOT / "release/README.txt").read_text(encoding="utf-8")
    missing = ["README.%s.md" % code for code in listed if translation_url(code) not in guide]
    if missing:
        fail("release/README.txt does not link to %s" % ", ".join(missing))
    return " · ".join("[%s](%s)" % (name, translation_url(code)) for code, name in TRANSLATIONS)


def current_commit():
    if os.environ.get("GITHUB_SHA"):
        return os.environ["GITHUB_SHA"]
    return subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True, check=True
    ).stdout.strip()


def main():
    if len(sys.argv) != 3:
        fail("usage: python release/build.py <version> <output directory>")
    version, out = sys.argv[1], pathlib.Path(sys.argv[2])
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        fail("the version must look like 1.2.3, not %r" % version)
    changes = changelog_section(version)
    translations = translations_line()

    name = "mt2-account-aliases-" + version
    out.mkdir(parents=True, exist_ok=True)
    archive = out / (name + ".zip")
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as zf:
        for path, source in FILES:
            data = (ROOT / source).read_bytes()
            if path in WINDOWS_TEXT:
                try:
                    data.decode("ascii")
                except UnicodeDecodeError:
                    fail("%s must be ASCII" % source)
                data = data.replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
            zf.writestr(name + "/" + path, data)

    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    (out / (name + ".zip.sha256")).write_text("%s  %s.zip\n" % (digest, name), encoding="ascii")
    notes = NOTES.format(
        translations=translations,
        changes=changes,
        name=name,
        digest=digest,
        commit=current_commit(),
        repository=REPOSITORY,
    )
    (out / "release-notes.md").write_text(notes, encoding="utf-8")
    print("%s  %s" % (digest, archive))


if __name__ == "__main__":
    main()
