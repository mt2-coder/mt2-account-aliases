# Metin2 Account Aliases

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) ·
**Italiano** · [Português](README.pt.md) · [Română](README.ro.md) · [Türkçe](README.tr.md)

[![Latest release](https://img.shields.io/github/v/release/mt2-coder/mt2-account-aliases)](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
[![License: MIT](https://img.shields.io/github/license/mt2-coder/mt2-account-aliases)](LICENSE)
[![Tests](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml/badge.svg)](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml)
[![Provenance: attested](https://img.shields.io/badge/provenance-attested-brightgreen)](https://github.com/mt2-coder/mt2-account-aliases/attestations)

*Traduzione della [versione inglese](README.md), aggiornata al 4 ottobre 2026. In caso di
differenze, fa fede la versione inglese.*

**Dai nomi leggibili ai tuoi account di Metin2 nel Gameforge Client e ritrovali per nome.**

Gli account di gioco non si possono mai rinominare, e sul server Tigerghost il launcher assegna
loro perfino identificativi generati come `playerg123456789`. Con decine di account, quattro per
pagina, trovare quello giusto diventa un indovinello. Questo add-on gratuito ti permette di
chiamarli `main`, `buff` o `meley1`, direttamente nell'elenco degli account del launcher.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Guarda la demo su YouTube](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[Scarica l'ultima versione](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
gratuito e open source ([MIT](LICENSE))

> Add-on non ufficiale: non è affiliato a Gameforge né approvato da Gameforge.

## Cosa fa

Nel launcher, **Impostazioni > Account di gioco**:

- **Dai un nome ai tuoi account.** La matita accanto al nome di un account gli assegna un alias:
  Invio salva, Esc annulla, un alias vuoto lo rimuove. L'alias compare per primo, il nome reale
  accanto, in piccolo e in grigio; un alias lungo viene tagliato sullo schermo e mostrato per
  intero nel tooltip.
- **Ritrovali per nome.** La casella di ricerca del launcher stesso (la lente sopra la tabella)
  trova gli account anche per alias, e le sue pagine continuano a funzionare.
- **Tieni un backup.** Il pulsante **Manage**, in basso a destra, mostra tutti i tuoi alias come
  testo: copialo per tenerne un backup, oppure incollalo e premi **Apply** per ripristinarlo o per
  spostare i tuoi alias su un altro PC.

L'add-on e il suo installer esistono solo in inglese: i pulsanti si chiamano **Manage**, **Copy** e
**Apply**, e i messaggi dell'installer sono in inglese.

## È sicuro?

L'add-on è costruito attorno a una regola: non mettere mai a rischio il tuo gioco o il tuo account.

- **Non tocca mai il gioco.** Né `metin2client.exe`, né alcun file del gioco, né il suo
  anti-cheat. Nessuna parte dell'add-on viene eseguita nel gioco.
- **È solo uno strato sopra la finestra del launcher.** L'interfaccia del launcher è una pagina
  web contenuta in un unico file, `resources\frontend.pak`. L'add-on aggiunge un piccolo script a
  quella pagina e nient'altro: il programma del launcher, e il modo in cui avvia il gioco, restano
  esattamente gli stessi.
- **Il tuo account resta intatto.** Gli alias esistono solo sul tuo PC: i nomi reali dei tuoi
  account non cambiano mai, né sul tuo PC né sui server di Gameforge. L'add-on non effettua alcuna
  richiesta di rete e non legge mai la tua password, la tua sessione o i dati del tuo account;
  legge solo i nomi degli account già visibili sullo schermo.
- **Puoi annullare tutto in qualsiasi momento.** L'installer fa un backup del file del launcher
  prima di modificarlo, e `Uninstall.cmd` rimette l'originale, byte per byte.
- **Niente è nascosto.** Nessun `.exe`: l'add-on è un unico file JavaScript che puoi leggere,
  [`src/alias-addon.js`](src/alias-addon.js), e l'installer un unico script PowerShell,
  [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Ogni versione viene compilata da GitHub a
  partire da questo codice pubblico ed è accompagnata dal suo hash SHA-256 e da
  un'[attestazione di provenienza](https://github.com/mt2-coder/mt2-account-aliases/attestations)
  (provenance attestation).

L'add-on è software libero con licenza MIT, il che significa che è fornito senza alcuna garanzia.

## Installazione

Ti servono Windows 10 o 11, il Gameforge Client e i diritti di amministratore.

1. Scarica `mt2-account-aliases-x.y.z.zip` dall'[ultima versione](https://github.com/mt2-coder/mt2-account-aliases/releases/latest).
2. Clic destro sullo ZIP > **Proprietà** > spunta **Annulla blocco** > **OK**, poi estrailo.
   Altrimenti Windows chiede una conferma ogni volta che avvii uno dei suoi file `.cmd`, perché
   non sono firmati digitalmente.
3. Chiudi i tuoi client di Metin2, poi chiudi completamente il Gameforge Client, compresa la sua
   icona nell'area di notifica.
4. Fai doppio clic su **`Install.cmd`** e clicca **Sì** nella richiesta di Windows (Controllo
   dell'account utente): i file del launcher si trovano in `Program Files` («Programmi» in Esplora
   file), quindi modificarli richiede i diritti di amministratore.
5. Avvia il launcher e apri **Impostazioni > Account di gioco**.

L'installer trova il launcher ovunque sia installato. Verificato con Gameforge Client 2.8.5.1959
(interfaccia 0.486.2).

I tuoi alias sono conservati dal launcher, solo su questo PC. Qualsiasi cosa cancelli i dati del
launcher li cancellerebbe, quindi tieni un backup con **Manage**.

## Disinstallazione

Chiudi il launcher, poi fai doppio clic su **`Uninstall.cmd`**: il file originale del launcher
torna al suo posto, byte per byte. I tuoi alias restano salvati nel launcher, quindi
reinstallandolo li ritrovi.

## Quando il launcher aggiorna la sua interfaccia

Il launcher non può aggiornare un'interfaccia modificata dall'add-on. Quando annuncia un
aggiornamento, o dice di non essere riuscito ad applicarne uno:

1. chiudilo, poi fai doppio clic su `Uninstall.cmd`;
2. avvia il launcher, lascialo aggiornare, poi chiudilo;
3. fai di nuovo doppio clic su `Install.cmd`.

## Risoluzione dei problemi

- **Cosa è installato?** `Status.cmd` te lo dice, senza cambiare nulla.
- **«Gameforge Client not found».** Apri un prompt dei comandi nella cartella estratta (scrivi
  `cmd` nella barra degli indirizzi di Esplora file, poi Invio) e indica il percorso del
  `frontend.pak` del launcher:
  `Install.cmd -PakPath "D:\Giochi\GameforgeClient\resources\frontend.pak"`.
- **Nessuna matita nell'elenco degli account.** Esegui `Install.cmd -Diagnostic` allo stesso modo.
  In basso a sinistra nella finestra principale del launcher compare una piccola etichetta che
  indica fin dove è arrivato l'add-on:

  | Etichetta | Significato |
  | --- | --- |
  | nessuna | il launcher non ha mostrato la pagina modificata |
  | rossa, `script did not run` | la pagina viene mostrata, ma l'add-on non è mai stato eseguito |
  | `active - no account on screen`, con l'elenco degli account aperto | l'add-on è in esecuzione ma non trova alcun account |
  | `active - 4 account(s) on screen (2 windows)` | l'elenco degli account è stato trovato e completato con gli alias |
  | `... error (...): ...` | il messaggio dice cosa non ha funzionato |

  `Install.cmd` senza `-Diagnostic` rimuove l'etichetta.
- **Il launcher è passato a un'altra lingua.** L'add-on non c'entra: l'icona del globo, in alto a
  destra nel launcher, la reimposta.

---

## Per gli sviluppatori e i team di Gameforge

La parte tecnica (come funziona l'add-on, come si potrebbe integrare la funzione nel launcher
stesso, test, rilasci) esiste solo in inglese:
[For developers and Gameforge's teams](README.md#for-developers-and-gameforges-teams).

## Licenza

[MIT](LICENSE). Copre solo questo repository: il Gameforge Client e i suoi file, compreso
`frontend.pak`, restano di proprietà di Gameforge.
