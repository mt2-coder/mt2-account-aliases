# Metin2 Account Aliases

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) ·
[Italiano](README.it.md) · [Português](README.pt.md) · **Română** · [Türkçe](README.tr.md)

[![Latest release](https://img.shields.io/github/v/release/mt2-coder/mt2-account-aliases?color=blue)](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
[![License: MIT](https://img.shields.io/github/license/mt2-coder/mt2-account-aliases)](LICENSE)
[![Tests](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml/badge.svg)](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml)
[![Provenance: attested](https://img.shields.io/badge/provenance-attested-brightgreen)](https://github.com/mt2-coder/mt2-account-aliases/attestations)

*Traducere a [versiunii în engleză](README.md), actualizată la 4 octombrie 2026. În caz de
diferențe, prevalează versiunea în engleză.*

**Dă conturilor tale de Metin2 nume ușor de citit în Gameforge Client și găsește-le după nume.**

Conturile de joc nu pot fi redenumite niciodată, iar pe serverul Tigerghost launcherul le dă chiar
identificatori generați precum `playerg123456789`. Cu zeci de conturi, câte patru pe pagină, să-l
găsești pe cel potrivit devine o ghicitoare. Acest add-on gratuit îți permite să le numești
`main`, `buff` sau `meley1`, direct în lista de conturi a launcherului.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Vezi demonstrația pe YouTube](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[Descarcă ultima versiune](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
gratuit și open source ([MIT](LICENSE))

> Add-on neoficial: nu este afiliat cu Gameforge și nu este susținut de Gameforge.

## Ce face

În launcher, **Setări > Cont de joc**:

- **Dă nume conturilor tale.** Creionul de lângă numele unui cont îi dă un alias: Enter salvează,
  Esc anulează, un alias gol îl șterge. Aliasul apare primul, iar numele real lângă el, cu litere
  mici și gri; un alias lung este tăiat pe ecran și afișat întreg în tooltip.
- **Găsește-le după nume.** Căsuța de căutare a launcherului (lupa de deasupra tabelului) găsește
  conturile și după alias, iar paginile ei funcționează în continuare.
- **Păstrează o copie de rezervă.** Butonul **Manage**, din dreapta jos, afișează toate aliasurile
  tale ca text: copiază-l ca să păstrezi o copie de rezervă, sau lipește-l și apasă **Apply** ca
  s-o restaurezi sau ca să-ți muți aliasurile pe alt PC.

Add-onul și programul său de instalare există doar în engleză: butoanele se numesc **Manage**,
**Copy** și **Apply**, iar mesajele programului de instalare apar în engleză.

## Este sigur?

Add-onul este construit în jurul unei singure reguli: să nu pună niciodată în pericol jocul sau
contul tău.

- **Nu atinge niciodată jocul.** Nici `metin2client.exe`, nici vreun fișier al jocului, nici
  anti-cheat-ul lui. Nicio parte a add-onului nu rulează în joc.
- **Este doar un strat peste fereastra launcherului.** Interfața launcherului este o pagină web
  stocată într-un singur fișier, `resources\frontend.pak`. Add-onul adaugă un mic script în acea
  pagină și nimic altceva: programul launcherului și felul în care pornește jocul rămân exact la
  fel.
- **Contul tău rămâne neatins.** Aliasurile există doar pe PC-ul tău: numele reale ale conturilor
  tale nu se schimbă niciodată, nici pe PC-ul tău, nici pe serverele Gameforge. Add-onul nu face
  nicio cerere în rețea și nu citește niciodată parola, sesiunea sau datele contului tău; citește
  doar numele conturilor deja afișate pe ecran.
- **Poți anula totul oricând.** Programul de instalare face o copie de rezervă a fișierului
  launcherului înainte să-l modifice, iar `Uninstall.cmd` pune la loc originalul, byte cu byte.
- **Nimic nu e ascuns.** Niciun `.exe`: add-onul este un singur fișier JavaScript pe care îl poți
  citi, [`src/alias-addon.js`](src/alias-addon.js), iar programul de instalare un singur script
  PowerShell, [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Fiecare versiune este
  construită de GitHub din acest cod public și vine cu hash-ul ei SHA-256 și cu o
  [atestare a provenienței](https://github.com/mt2-coder/mt2-account-aliases/attestations)
  (provenance attestation).

Add-onul este software liber sub licența MIT, ceea ce înseamnă că este oferit fără nicio garanție.

## Instalare

Ai nevoie de Windows 10 sau 11, de Gameforge Client și de drepturi de administrator.

1. Descarcă `mt2-account-aliases-x.y.z.zip` din
   [ultima versiune](https://github.com/mt2-coder/mt2-account-aliases/releases/latest) și
   dezarhivează-l.
2. Închide Metin2 și Gameforge Client, inclusiv pictograma lui din zona de notificare.
3. Fă dublu clic pe **`Install.cmd`**. Dacă Windows întreabă, apasă **Executare** (Run), apoi
   **Da**.
4. Pornește launcherul și deschide **Setări > Cont de joc**.

Programul de instalare găsește launcherul oriunde ar fi instalat. Verificat cu Gameforge Client
2.8.5.1959 (interfața 0.486.2).

Aliasurile tale sunt păstrate de launcher, doar pe acest PC. Orice șterge datele launcherului le-ar
șterge și pe ele, așa că păstrează o copie de rezervă cu **Manage**.

## Dezinstalare

Închide launcherul, apoi fă dublu clic pe **`Uninstall.cmd`**: fișierul original al launcherului
revine, byte cu byte. Aliasurile tale rămân salvate în launcher, așa că o nouă instalare le aduce
înapoi.

## Când launcherul își actualizează interfața

Launcherul nu poate actualiza o interfață pe care add-onul a modificat-o. Când anunță o
actualizare sau spune că nu a putut aplica una:

1. închide-l, apoi fă dublu clic pe `Uninstall.cmd`;
2. pornește launcherul, lasă-l să se actualizeze, apoi închide-l;
3. fă din nou dublu clic pe `Install.cmd`.

## Depanare

- **Ce este instalat?** `Status.cmd` îți spune, fără să schimbe nimic.
- **„Gameforge Client not found”.** Deschide un prompt de comandă în folderul dezarhivat (scrie
  `cmd` în bara de adrese din Explorer, apoi Enter) și indică calea către `frontend.pak` al
  launcherului: `Install.cmd -PakPath "D:\Jocuri\GameforgeClient\resources\frontend.pak"`.
- **Nu apar creioane în lista de conturi.** Rulează `Install.cmd -Diagnostic` în același fel. În
  stânga jos a ferestrei principale a launcherului apare o mică etichetă care arată până unde a
  ajuns add-onul:

  | Etichetă | Semnificație |
  | --- | --- |
  | niciuna | launcherul nu a afișat pagina modificată |
  | roșie, `script did not run` | pagina este afișată, dar add-onul nu a rulat niciodată |
  | `active - no account on screen`, cu lista de conturi deschisă | add-onul rulează, dar nu găsește niciun cont |
  | `active - 4 account(s) on screen (2 windows)` | lista de conturi a fost găsită și completată cu aliasurile |
  | `... error (...): ...` | mesajul spune ce a eșuat |

  `Install.cmd` fără `-Diagnostic` elimină eticheta.
- **Launcherul a trecut la altă limbă.** Add-onul nu are nicio legătură cu asta: pictograma cu
  globul, din dreapta sus a launcherului, o readuce.

---

## Pentru dezvoltatori și echipele Gameforge

Partea tehnică (cum funcționează add-onul, cum ar putea fi integrată funcția în launcherul însuși,
teste, versiuni) există doar în engleză:
[For developers and Gameforge's teams](README.md#for-developers-and-gameforges-teams).

## Licență

[MIT](LICENSE). Acoperă doar acest depozit: Gameforge Client și fișierele lui, inclusiv
`frontend.pak`, rămân ale Gameforge.
