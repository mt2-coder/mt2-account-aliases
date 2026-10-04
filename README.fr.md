# Metin2 Account Aliases

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · **Français** ·
[Italiano](README.it.md) · [Português](README.pt.md) · [Română](README.ro.md) · [Türkçe](README.tr.md)

[![Latest release](https://img.shields.io/github/v/release/mt2-coder/mt2-account-aliases?color=blue)](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
[![License: MIT](https://img.shields.io/github/license/mt2-coder/mt2-account-aliases)](LICENSE)
[![Tests](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml/badge.svg)](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml)
[![Provenance: attested](https://img.shields.io/badge/provenance-attested-brightgreen)](https://github.com/mt2-coder/mt2-account-aliases/attestations)

*Traduction de la [version anglaise](README.md), à jour au 4 octobre 2026. En cas de différence,
la version anglaise fait foi.*

**Donnez à vos comptes Metin2 des noms lisibles dans le Gameforge Client, et retrouvez-les par leur
nom.**

Les comptes de jeu ne peuvent jamais être renommés, et sur le serveur Tigerghost le launcher leur
donne même des identifiants générés comme `playerg123456789`. Avec des dizaines de comptes affichés
quatre par page, trouver le bon tient de la devinette. Cet add-on gratuit vous permet de les
appeler `main`, `buff` ou `meley1`, directement dans la liste de comptes du launcher.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Voir la démo sur YouTube](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[Télécharger la dernière version](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
gratuit et open source ([MIT](LICENSE))

> Add-on non officiel : ni affilié à Gameforge, ni approuvé par Gameforge.

## Ce qu'il fait

Dans le launcher, **Paramètres > Compte de jeu** :

- **Nommez vos comptes.** Le crayon à côté du nom d'un compte lui donne un alias : Entrée
  enregistre, Échap annule, un alias vide le supprime. L'alias vient en premier, le vrai nom à
  côté en petits caractères gris ; un alias long est coupé à l'écran et affiché en entier dans
  l'info-bulle.
- **Retrouvez-les par leur nom.** Le champ de recherche du launcher lui-même (la loupe au-dessus du
  tableau) trouve aussi les comptes par leur alias, et ses pages continuent de fonctionner.
- **Gardez une sauvegarde.** Le bouton **Manage**, en bas à droite, affiche tous vos alias sous
  forme de texte : copiez-le pour garder une sauvegarde, ou collez-le et appuyez sur **Apply** pour
  la restaurer ou transférer vos alias sur un autre PC.

L'add-on et son installateur n'existent qu'en anglais : les boutons s'appellent **Manage**,
**Copy** et **Apply**, et les messages de l'installateur sont en anglais.

## Est-ce sûr ?

L'add-on est construit autour d'une règle : ne jamais mettre en danger votre jeu ni votre compte.

- **Il ne touche jamais au jeu.** Ni à `metin2client.exe`, ni à aucun fichier du jeu, ni à son
  anti-triche. Aucune partie de l'add-on ne s'exécute dans le jeu.
- **Ce n'est qu'une couche par-dessus la fenêtre du launcher.** L'interface du launcher est une
  page web stockée dans un seul fichier, `resources\frontend.pak`. L'add-on ajoute un petit script
  à cette page et rien d'autre : le programme du launcher, et la façon dont il lance le jeu,
  restent exactement les mêmes.
- **Votre compte n'est pas touché.** Les alias n'existent que sur votre PC : les vrais noms de vos
  comptes ne changent jamais, ni sur votre PC ni sur les serveurs de Gameforge. L'add-on ne fait
  aucune requête réseau et ne lit jamais votre mot de passe, votre session ou les données de votre
  compte ; il lit seulement les noms de comptes déjà affichés à l'écran.
- **Vous pouvez tout annuler à tout moment.** L'installateur sauvegarde le fichier du launcher
  avant de le modifier, et `Uninstall.cmd` remet l'original, octet pour octet.
- **Rien n'est caché.** Aucun `.exe` : l'add-on est un seul fichier JavaScript que vous pouvez
  lire, [`src/alias-addon.js`](src/alias-addon.js), et l'installateur un seul script PowerShell,
  [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Chaque version est construite par GitHub à
  partir de ce code public et accompagnée de son empreinte SHA-256 et d'une
  [attestation de provenance](https://github.com/mt2-coder/mt2-account-aliases/attestations).

L'add-on est un logiciel libre sous licence MIT, ce qui signifie qu'il est fourni sans garantie.

## Installation

Il vous faut Windows 10 ou 11, le Gameforge Client et les droits d'administrateur.

1. Téléchargez `mt2-account-aliases-x.y.z.zip` depuis la
   [dernière version](https://github.com/mt2-coder/mt2-account-aliases/releases/latest).
2. Clic droit sur le ZIP > **Propriétés** > cochez **Débloquer** > **OK**, puis extrayez-le.
   Sinon, Windows demande une confirmation chaque fois que vous lancez l'un de ses fichiers
   `.cmd`, car ils ne sont pas signés numériquement.
3. Fermez vos clients Metin2, puis fermez complètement le Gameforge Client, y compris son icône
   dans la zone de notification.
4. Double-cliquez sur **`Install.cmd`** et cliquez sur **Oui** dans la fenêtre de Windows
   (contrôle de compte d'utilisateur) : les fichiers du launcher se trouvent sous `Program Files`
   (« Programmes » dans l'Explorateur), donc les modifier demande les droits d'administrateur.
5. Lancez le launcher et ouvrez **Paramètres > Compte de jeu**.

L'installateur trouve le launcher où qu'il soit installé. Vérifié avec Gameforge Client
2.8.5.1959 (interface 0.486.2).

Vos alias sont conservés par le launcher, sur ce PC uniquement. Tout ce qui efface les données du
launcher les effacerait aussi : gardez donc une sauvegarde avec **Manage**.

## Désinstallation

Fermez le launcher, puis double-cliquez sur **`Uninstall.cmd`** : le fichier d'origine du launcher
revient, octet pour octet. Vos alias restent enregistrés dans le launcher : une nouvelle
installation les fait revenir.

## Quand le launcher met à jour son interface

Le launcher ne peut pas mettre à jour une interface que l'add-on a modifiée. Quand il annonce une
mise à jour, ou indique qu'il n'a pas pu en appliquer une :

1. fermez-le, puis double-cliquez sur `Uninstall.cmd` ;
2. lancez le launcher, laissez-le se mettre à jour, puis fermez-le ;
3. double-cliquez à nouveau sur `Install.cmd`.

## Dépannage

- **Qu'est-ce qui est installé ?** `Status.cmd` vous le dit, sans rien changer.
- **« Gameforge Client not found ».** Ouvrez une invite de commandes dans le dossier extrait (tapez
  `cmd` dans la barre d'adresse de l'Explorateur de fichiers, puis Entrée) et indiquez le chemin du
  `frontend.pak` du launcher :
  `Install.cmd -PakPath "D:\Jeux\GameforgeClient\resources\frontend.pak"`.
- **Pas de crayons dans la liste des comptes.** Lancez `Install.cmd -Diagnostic` de la même façon.
  Une petite étiquette apparaît en bas à gauche de la fenêtre principale du launcher et indique
  jusqu'où l'add-on est allé :

  | Étiquette | Signification |
  | --- | --- |
  | aucune | le launcher n'a pas affiché la page modifiée |
  | rouge, `script did not run` | la page est affichée, mais l'add-on ne s'est jamais exécuté |
  | `active - no account on screen`, avec la liste des comptes ouverte | l'add-on s'exécute mais ne trouve aucun compte |
  | `active - 4 account(s) on screen (2 windows)` | la liste des comptes est trouvée et complétée par les alias |
  | `... error (...): ...` | le message dit ce qui a échoué |

  `Install.cmd` sans `-Diagnostic` retire l'étiquette.
- **Le launcher est passé dans une autre langue.** L'add-on n'y est pour rien : l'icône du globe,
  en haut à droite du launcher, la rétablit.

---

## Pour les développeurs et les équipes de Gameforge

La partie technique (le fonctionnement de l'add-on, comment intégrer la fonction au launcher
lui-même, les tests, les versions) n'existe qu'en anglais :
[For developers and Gameforge's teams](README.md#for-developers-and-gameforges-teams).

## Licence

[MIT](LICENSE). Elle ne couvre que ce dépôt : le Gameforge Client et ses fichiers, y compris
`frontend.pak`, restent la propriété de Gameforge.
