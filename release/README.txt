mt2-account-aliases
===================

Readable aliases for your Metin2 game accounts in the Gameforge Client.

Auf Deutsch: https://github.com/mt2-coder/mt2-account-aliases/blob/main/README.de.md

Unofficial: not affiliated with or endorsed by Gameforge. It modifies one file of the launcher
and never touches the game client. Use it at your own risk.


What it does
------------

In the launcher, Settings > Game account:

- the pencil next to an account name gives it an alias: Enter saves, Escape cancels, an empty
  alias removes it;
- the table's search box also finds accounts by alias;
- the "Manage" button, bottom right, shows every alias as JSON: copy it to keep a backup, or
  paste it and press "Apply" to restore a backup or to move your aliases to another PC.


Install
-------

1. Close your Metin2 clients, then close the Gameforge Client completely, including its icon in
   the notification area (bottom right of the taskbar).
2. Double-click Install.cmd. Windows asks twice:
   - "Open File - Security Warning: The publisher could not be verified": click "Run". The files
     come from the internet and carry no digital signature (signing needs a paid certificate);
   - the administrator prompt (UAC): click "Yes". The launcher's files sit under Program Files,
     so changing one needs administrator rights.
3. Start the launcher and open Settings > Game account.

The security warning comes back every time you run a .cmd file. To stop it, unblock the ZIP
before extracting it: right-click it > Properties > tick "Unblock" > OK, then extract it again.


Uninstall
---------

Close the launcher, then double-click Uninstall.cmd. The launcher's original file is restored
byte for byte. Your aliases stay stored in the launcher: installing again brings them back.


When the launcher updates its interface
---------------------------------------

The launcher cannot update an interface that the add-on has modified. When it announces an
update, or reports that it could not apply one:

1. close it, then double-click Uninstall.cmd;
2. start the launcher, let it update, then close it;
3. double-click Install.cmd again.

Status.cmd tells you at any time what is installed. It changes nothing.


Your aliases
------------

The launcher keeps them on this PC only. Anything that clears the launcher's data would lose
them, so keep a backup with the "Manage" button.


What it touches
---------------

Only resources\frontend.pak in the Gameforge Client's folder, backed up first next to it as
frontend.pak.alias-backup. Never the game, its files or its anti-cheat. The add-on makes no
network request and never reads your session, cookies or account data.

Everything here is plain text that you can read: src\alias-addon.js is the add-on,
scripts\alias-addon.ps1 the installer, and the .cmd files only start the installer.


Source code and licence (MIT)
-----------------------------

https://github.com/mt2-coder/mt2-account-aliases
