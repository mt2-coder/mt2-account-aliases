# Metin2 Account Aliases

[English](README.md) · **Deutsch** · [Español](README.es.md) · [Français](README.fr.md) ·
[Italiano](README.it.md) · [Português](README.pt.md) · [Română](README.ro.md) · [Türkçe](README.tr.md)

[![Latest release](https://img.shields.io/github/v/release/mt2-coder/mt2-account-aliases?color=blue)](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
[![License: MIT](https://img.shields.io/github/license/mt2-coder/mt2-account-aliases)](LICENSE)
[![Tests](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml/badge.svg)](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml)
[![Provenance: attested](https://img.shields.io/badge/provenance-attested-brightgreen)](https://github.com/mt2-coder/mt2-account-aliases/attestations)

*Übersetzung der [englischen Fassung](README.md), Stand: 4. Oktober 2026. Bei Abweichungen gilt
die englische Fassung.*

**Gib deinen Metin2-Spielaccounts im Gameforge Client lesbare Namen und finde sie über diese Namen
wieder.**

Spielaccounts lassen sich nie umbenennen, und auf dem Server Tigerghost gibt ihnen der Launcher
sogar generierte Namen wie `playerg123456789`. Bei Dutzenden Accounts, vier pro Seite, wird die
Suche nach dem richtigen zum Ratespiel. Mit diesem kostenlosen Add-on nennst du sie stattdessen
`main`, `buff` oder `meley1`, direkt in der Accountliste des Launchers.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Demo auf YouTube ansehen](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[Neueste Version herunterladen](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
kostenlos und Open Source ([MIT](LICENSE))

> Inoffizielles Add-on: weder mit Gameforge verbunden noch von Gameforge unterstützt.

## Was es macht

Im Launcher unter **Einstellungen > Spielaccount**:

- **Gib deinen Accounts Namen.** Mit dem Stift neben einem Accountnamen gibst du ihm einen Alias:
  Enter speichert, Escape bricht ab, ein leerer Alias entfernt ihn. Der Alias steht vorne, der
  echte Name klein und grau daneben; ein langer Alias wird auf dem Bildschirm gekürzt und im
  Tooltip vollständig angezeigt.
- **Finde sie über ihren Namen.** Das Suchfeld des Launchers selbst (die Lupe über der Tabelle)
  findet Accounts auch über ihren Alias, und das Blättern zwischen den Seiten funktioniert weiter.
- **Leg eine Sicherung an.** Die Schaltfläche **Manage** unten rechts zeigt alle deine Aliase als
  Text: Kopiere ihn als Sicherung, oder füge ihn ein und klicke auf **Apply**, um die Sicherung
  wiederherzustellen oder deine Aliase auf einen anderen PC zu übertragen.

Das Add-on und sein Installer gibt es nur auf Englisch: Die Schaltflächen heißen **Manage**,
**Copy** und **Apply**, und auch die Meldungen des Installers sind englisch.

## Ist es sicher?

Für das Add-on gilt eine Regel: Es darf weder dein Spiel noch deinen Account gefährden.

- **Es lässt das Spiel unangetastet.** Weder `metin2client.exe` noch irgendeine Datei des Spiels
  noch dessen Anti-Cheat. Nichts vom Add-on läuft im Spiel.
- **Es ist nur eine Ebene über dem Fenster des Launchers.** Die Oberfläche des Launchers ist eine
  Webseite, die in einer einzigen Datei liegt: `resources\frontend.pak`. Das Add-on fügt dieser
  Seite ein kleines Skript hinzu und sonst nichts: Das Programm des Launchers und die Art, wie er
  das Spiel startet, bleiben genau gleich.
- **Dein Account bleibt unberührt.** Aliase gibt es nur auf deinem PC: Deine echten Accountnamen
  ändern sich nie, weder auf deinem PC noch auf den Servern von Gameforge. Das Add-on stellt
  überhaupt keine Netzwerkanfragen und liest nie dein Passwort, deine Sitzung oder deine
  Accountdaten; es liest nur die Accountnamen, die schon auf dem Bildschirm stehen.
- **Du kannst es jederzeit rückgängig machen.** Der Installer sichert die Datei des Launchers,
  bevor er sie ändert, und `Uninstall.cmd` stellt das Original wieder her, Byte für Byte.
- **Nichts ist versteckt.** Keine `.exe`: Das Add-on ist eine einzige JavaScript-Datei, die du
  lesen kannst, [`src/alias-addon.js`](src/alias-addon.js), und der Installer ein einziges
  PowerShell-Skript, [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Jede Version wird von
  GitHub aus diesem öffentlichen Code gebaut und kommt mit ihrer SHA-256-Prüfsumme und einem
  [Herkunftsnachweis](https://github.com/mt2-coder/mt2-account-aliases/attestations) (provenance
  attestation).

Das Add-on ist freie Software unter der MIT-Lizenz, das heißt: ohne jede Gewährleistung.

## Installation

Du brauchst Windows 10 oder 11, den Gameforge Client und Administratorrechte.

1. Lade `mt2-account-aliases-x.y.z.zip` aus der
   [neuesten Version](https://github.com/mt2-coder/mt2-account-aliases/releases/latest) herunter
   und entpacke die Datei.
2. Schließe Metin2 und den Gameforge Client, auch sein Symbol im Infobereich der Taskleiste.
3. Doppelklicke auf **`Install.cmd`**. Falls Windows nachfragt, klicke auf **Ausführen**, dann auf
   **Ja**.
4. Starte den Launcher und öffne **Einstellungen > Spielaccount**.

Der Installer findet den Launcher, egal wo er installiert ist. Geprüft mit Gameforge Client
2.8.5.1959 (Oberfläche 0.486.2).

Deine Aliase speichert der Launcher nur auf diesem PC. Alles, was die Daten des Launchers löscht,
würde sie auch löschen, also leg mit **Manage** eine Sicherung an.

## Deinstallation

Schließe den Launcher, dann doppelklicke auf **`Uninstall.cmd`**: Die Originaldatei des Launchers
kommt zurück, Byte für Byte. Deine Aliase bleiben im Launcher gespeichert, eine erneute
Installation bringt sie also zurück.

## Wenn der Launcher seine Oberfläche aktualisiert

Der Launcher kann eine Oberfläche, die das Add-on verändert hat, nicht aktualisieren. Wenn er ein
Update ankündigt oder meldet, dass er eines nicht anwenden konnte:

1. Schließe ihn, dann doppelklicke auf `Uninstall.cmd`.
2. Starte den Launcher, lass ihn aktualisieren, dann schließe ihn.
3. Doppelklicke wieder auf `Install.cmd`.

## Fehlerbehebung

- **Was ist installiert?** `Status.cmd` sagt es dir und ändert nichts.
- **„Gameforge Client not found“.** Öffne eine Eingabeaufforderung im entpackten Ordner (tippe
  `cmd` in die Adressleiste des Datei-Explorers, dann Enter) und gib den Pfad der `frontend.pak`
  des Launchers an:
  `Install.cmd -PakPath "D:\Spiele\GameforgeClient\resources\frontend.pak"`.
- **Keine Stifte in der Accountliste.** Führe `Install.cmd -Diagnostic` auf dieselbe Weise aus.
  Unten links im Hauptfenster des Launchers erscheint eine kleine Anzeige und zeigt, wie weit das
  Add-on gekommen ist:

  | Anzeige | Bedeutung |
  | --- | --- |
  | gar keine | der Launcher hat die veränderte Seite nicht angezeigt |
  | rot, `script did not run` | die Seite wird angezeigt, aber das Add-on ist nie gelaufen |
  | `active - no account on screen`, bei geöffneter Accountliste | das Add-on läuft, findet aber keinen Account |
  | `active - 4 account(s) on screen (2 windows)` | die Accountliste wurde gefunden und erweitert |
  | `... error (...): ...` | die Meldung sagt, was fehlgeschlagen ist |

  `Install.cmd` ohne `-Diagnostic` entfernt die Anzeige wieder.
- **Der Launcher hat die Sprache gewechselt.** Das Add-on hat damit nichts zu tun: Das
  Globus-Symbol oben rechts im Launcher stellt sie zurück.

---

## Für Entwickler und die Teams von Gameforge

Den technischen Teil (wie das Add-on funktioniert, wie die Funktion in den Launcher selbst eingebaut
werden könnte, Tests, Releases) gibt es nur auf Englisch:
[For developers and Gameforge's teams](README.md#for-developers-and-gameforges-teams).

## Lizenz

[MIT](LICENSE). Sie gilt nur für dieses Repository: Der Gameforge Client und seine Dateien,
einschließlich `frontend.pak`, gehören weiterhin Gameforge.
