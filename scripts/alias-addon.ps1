<#
.SYNOPSIS
  Installs, reverts or reports the alias add-on in the Gameforge Client UI.

.DESCRIPTION
  The launcher UI is a React app packed in resources\frontend.pak, a plain ZIP.

    install  Backs frontend.pak up next to itself (frontend.pak.alias-backup), then
             inlines src\alias-addon.js as a <script> just before </body> in index.html,
             between marker comments. Run it again after editing the add-on to update it.
    revert   Restores the backup byte for byte, then deletes it.
    status   Changes nothing; reports what is installed.

  install -Diagnostic also injects a small CSS label, bottom left of the launcher's main
  window, that shows how far the add-on got, for all its windows: nothing at all means the
  launcher did not display this index.html; "script did not run" means the <script> never
  ran; otherwise it shows the add-on's state or error. "install" without the switch
  removes the label.

  The launcher must be closed. Writing under Program Files needs admin rights: when the
  current session lacks them, the script relaunches itself elevated (UAC prompt) and
  relays the output here. Runs on Windows PowerShell 5.1 and PowerShell 7.

  The launcher patches frontend.pak with binary deltas (xdelta3), which cannot apply to a
  modified file. When it announces a frontend update or fails to apply one: close it, run
  "revert", start it to let it update, close it, then run "install" again.

.EXAMPLE
  .\scripts\alias-addon.ps1 status

.EXAMPLE
  .\scripts\alias-addon.ps1 install

.EXAMPLE
  .\scripts\alias-addon.ps1 install -Diagnostic

.EXAMPLE
  .\scripts\alias-addon.ps1 revert
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet('status', 'install', 'revert')]
  [string]$Action = 'status',

  # frontend.pak to work on. Default: the Gameforge Client install found in the registry.
  [string]$PakPath,

  # Add-on to inject. Default: src\alias-addon.js of this repo (set below: Windows
  # PowerShell 5.1 leaves $PSScriptRoot empty in param defaults under -File).
  [string]$AddonPath,

  # install only: add the diagnostic label (see above).
  [switch]$Diagnostic,

  # Internal: set by the elevated relaunch, which writes its output there.
  [string]$LogPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Utf8 = New-Object System.Text.UTF8Encoding($false)
# Everything the add-on adds to index.html sits between these two comments, so it can be
# found, updated or cut out exactly. "orig" is the sha256 of the untouched frontend.pak.
$BeginMark = '<!--gf-alias-addon:begin'
$BeginRx = '<!--gf-alias-addon:begin v=1 addon=([0-9a-f]{64}) orig=([0-9a-f]{64})-->'
$BlockRx = '<!--gf-alias-addon:begin [^>]*-->[\s\S]*?<!--gf-alias-addon:end-->'
# data-cookieconsent="ignore" like the stock inline scripts, so a consent manager never blocks it.
$ScriptOpen = '<script id="gf-alias-addon" data-cookieconsent="ignore">'
$ScriptClose = '</script><!--gf-alias-addon:end-->'
# Diagnostic label: pure CSS, so it shows even if the script never runs. The add-on
# publishes its state in body[data-gf-alias-state].
$ProbeOpen = '<style id="gf-alias-probe">'
$Probe = $ProbeOpen +
  'body::after{content:"alias: script did not run";position:fixed;left:6px;bottom:6px;z-index:2147483647;' +
  'pointer-events:none;font:12px/1.4 sans-serif;color:#fff;background:#b3261e;padding:2px 8px;border-radius:4px;white-space:nowrap}' +
  'body[data-gf-alias-state]::after{content:"alias: " attr(data-gf-alias-state);background:#00496b}</style>'
# gfclient.exe holds frontend.pak open; SparkWebHelper.exe are its CEF renderers.
$LauncherProcesses = 'gfclient', 'SparkWebHelper'

# ---- output (relayed through -LogPath by the elevated relaunch) ----------------

function Say([string]$Text, [ConsoleColor]$Color = 'Gray') {
  Write-Host $Text -ForegroundColor $Color
  if ($LogPath) { [IO.File]::AppendAllText($LogPath, "$Color`t$Text`r`n", $Utf8) }
}

# ---- helpers -------------------------------------------------------------------

function Get-Sha256([byte[]]$Bytes) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes)) -replace '-', '').ToLowerInvariant() }
  finally { $sha.Dispose() }
}

function Get-FileSha([string]$Path) {
  return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Short([string]$Sha) { return $Sha.Substring(0, 12) }

function Read-EntryBytes($Entry) {
  $src = $Entry.Open()
  $buf = New-Object IO.MemoryStream
  try { $src.CopyTo($buf); return , $buf.ToArray() }
  finally { $src.Dispose(); $buf.Dispose() }
}

function Find-Pak {
  if ($PakPath) {
    if (-not (Test-Path -LiteralPath $PakPath -PathType Leaf)) { throw "frontend.pak not found: $PakPath" }
    return (Resolve-Path -LiteralPath $PakPath).ProviderPath
  }
  $roots = New-Object System.Collections.Generic.List[string]
  $keys = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
          'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
          'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
  foreach ($app in @(Get-ItemProperty -Path $keys -ErrorAction SilentlyContinue)) {
    $props = $app.PSObject.Properties
    if ($props['DisplayName'] -and $app.DisplayName -eq 'Gameforge Client' -and $props['InstallLocation'] -and $app.InstallLocation) {
      $roots.Add($app.InstallLocation)
    }
  }
  $roots.Add((Join-Path ${env:ProgramFiles(x86)} 'GameforgeClient'))
  $roots.Add((Join-Path $env:ProgramFiles 'GameforgeClient'))
  foreach ($root in $roots) {
    $candidate = Join-Path $root 'resources\frontend.pak'
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).ProviderPath }
  }
  throw 'frontend.pak not found: give its path with -PakPath.'
}

function Get-LauncherVersion {
  $exe = Join-Path (Split-Path (Split-Path $pak)) 'gfclient.exe'
  if (Test-Path -LiteralPath $exe) { return (Get-Item -LiteralPath $exe).VersionInfo.ProductVersion }
  return '(unknown version)'
}

function Get-RunningLauncher {
  return @(Get-Process -Name $LauncherProcesses -ErrorAction SilentlyContinue | ForEach-Object { $_.ProcessName } | Sort-Object -Unique)
}

function Assert-LauncherClosed {
  # Only a launcher started from this install holds this pak; a copy can be patched anytime.
  # A process whose path can't be read counts as holding it.
  $holders = @(Get-Process -Name $LauncherProcesses -ErrorAction SilentlyContinue | Where-Object {
      -not $_.Path -or $pak.StartsWith((Split-Path $_.Path) + '\', [StringComparison]::OrdinalIgnoreCase)
    })
  if ($holders.Count) {
    throw ('The launcher is running ({0}): close it completely, notification-area icon included, then try again.' -f
      (($holders | ForEach-Object { $_.ProcessName } | Sort-Object -Unique) -join ', '))
  }
}

function Test-CanWrite([string]$Dir) {
  $probe = Join-Path $Dir ('.alias-probe-' + [guid]::NewGuid().ToString('N'))
  try {
    [IO.File]::Open($probe, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write).Dispose()
  } catch [UnauthorizedAccessException] {
    return $false
  }
  Remove-Item -LiteralPath $probe -Force
  return $true
}

# Returns when this session can write next to frontend.pak. Otherwise reruns the script
# elevated (UAC), relays its output and exits with its exit code.
function Assert-Writable {
  if (Test-CanWrite (Split-Path $pak)) { return }
  if ($LogPath) { throw "Writing refused in $(Split-Path $pak), even as administrator." }
  $log = Join-Path ([IO.Path]::GetTempPath()) ('gf-alias-addon-' + [guid]::NewGuid().ToString('N') + '.log')
  $exe = (Get-Process -Id $PID).Path
  # The elevated session does not inherit this one's execution policy: without Bypass, Windows
  # PowerShell's default policy (Restricted) would refuse to run this script there.
  $argLine = '-NoProfile -ExecutionPolicy Bypass -File "{0}" {1} -PakPath "{2}" -AddonPath "{3}" -LogPath "{4}"' -f $PSCommandPath, $Action, $pak, $addon, $log
  if ($Diagnostic) { $argLine += ' -Diagnostic' }
  Say 'Administrator rights are needed to modify frontend.pak: accept the UAC prompt.' Yellow
  try {
    $child = Start-Process -FilePath $exe -ArgumentList $argLine -Verb RunAs -Wait -PassThru
  } catch {
    throw "Elevation refused or impossible: nothing was changed."
  }
  try {
    if (Test-Path -LiteralPath $log) {
      foreach ($line in [IO.File]::ReadAllLines($log, $Utf8)) {
        $parts = $line -split "`t", 2
        if ($parts.Count -eq 2) { Write-Host $parts[1] -ForegroundColor $parts[0] } else { Write-Host $line }
      }
    } else {
      Write-Host "The administrator session returned nothing." -ForegroundColor Yellow
    }
  } finally {
    Remove-Item -LiteralPath $log -Force -ErrorAction SilentlyContinue
  }
  exit $child.ExitCode
}

# ---- add-on and index.html -----------------------------------------------------

function Get-Addon {
  if (-not (Test-Path -LiteralPath $addon -PathType Leaf)) { throw "Add-on not found: $addon" }
  $code = [IO.File]::ReadAllText($addon, $Utf8)
  # Inlined as-is: either sequence would end or derail the <script> element early.
  if ($code -match '</script|<!--') {
    throw "The add-on contains '</script' or '<!--', which would break the <script> element: write them '<\/script' or '<\!--'."
  }
  return $code, (Get-Sha256 ($Utf8.GetBytes($code)))
}

function Get-PakState {
  $zip = [IO.Compression.ZipFile]::OpenRead($pak)
  try {
    $entry = $zip.GetEntry('index.html')
    if (-not $entry) { throw "index.html missing from ${pak}: unexpected format, nothing was changed." }
    $html = $Utf8.GetString((Read-EntryBytes $entry))
  } finally { $zip.Dispose() }
  $state = [pscustomobject]@{
    Html = $html; Installed = $html.Contains($BeginMark); AddonSha = $null; OrigSha = $null; Intact = $false
    Diagnostic = $html.Contains($ProbeOpen)
  }
  if ($state.Installed) {
    $m = [regex]::Match($html, $BeginRx)
    if (-not $m.Success) { throw "Unreadable add-on marker in index.html." }
    $state.AddonSha = $m.Groups[1].Value
    $state.OrigSha = $m.Groups[2].Value
    $inline = [regex]::Match($html, [regex]::Escape($ScriptOpen + "`n") + '([\s\S]*?)' + [regex]::Escape("`n" + $ScriptClose))
    $state.Intact = $inline.Success -and ((Get-Sha256 ($Utf8.GetBytes($inline.Groups[1].Value))) -eq $state.AddonSha)
  }
  return $state
}

function New-Block([string]$Code, [string]$AddonSha, [string]$OrigSha) {
  $label = ''
  if ($Diagnostic) { $label = $Probe }
  return "<!--gf-alias-addon:begin v=1 addon=$AddonSha orig=$OrigSha-->" + $label + $ScriptOpen + "`n" + $Code + "`n" + $ScriptClose
}

function Add-Block([string]$Html, [string]$Block) {
  $at = $Html.LastIndexOf('</body>', [StringComparison]::OrdinalIgnoreCase)
  if ($at -lt 0) { throw "No </body> in index.html: unexpected format, nothing was changed." }
  return $Html.Substring(0, $at) + $Block + $Html.Substring($at)
}

function Remove-Block([string]$Html) {
  $rx = New-Object regex $BlockRx
  if (-not $rx.IsMatch($Html)) { throw "Incomplete add-on block in index.html: repair or reinstall the Gameforge Client." }
  return $rx.Replace($Html, '')
}

# ---- frontend.pak writes -------------------------------------------------------

# Every entry but index.html must come out of the rewrite unchanged.
function Assert-SameEntries([string]$Before, [string]$After, [string]$ExpectedHtml) {
  $a = [IO.Compression.ZipFile]::OpenRead($Before)
  try {
    $b = [IO.Compression.ZipFile]::OpenRead($After)
    try {
      if ($a.Entries.Count -ne $b.Entries.Count) { throw "Check: different number of entries." }
      foreach ($ea in $a.Entries) {
        $eb = $b.GetEntry($ea.FullName)
        if (-not $eb) { throw "Check: entry lost ($($ea.FullName))." }
        $bytes = Read-EntryBytes $eb
        if ($ea.FullName -eq 'index.html') {
          if ($Utf8.GetString($bytes) -cne $ExpectedHtml) { throw 'Check: the written index.html does not match.' }
        } elseif ((Get-Sha256 $bytes) -ne (Get-Sha256 (Read-EntryBytes $ea))) {
          throw "Check: $($ea.FullName) changed."
        }
      }
    } finally { $b.Dispose() }
  } finally { $a.Dispose() }
}

# Swaps $Tmp in place of frontend.pak in one rename: a failure never leaves a half-written file.
function Set-Pak([string]$Tmp) {
  $expected = Get-FileSha $Tmp
  [IO.File]::Replace($Tmp, $pak, [NullString]::Value)
  if ((Get-FileSha $pak) -ne $expected) { throw 'Check after replacement failed.' }
}

function Get-Crc32([byte[]]$Bytes) {
  # Longs kept within 0..2^32-1: PowerShell has no unsigned hex literals before 7.
  $table = New-Object 'long[]' 256
  for ($n = 0; $n -lt 256; $n++) {
    [long]$c = $n
    for ($k = 0; $k -lt 8; $k++) {
      if ($c -band 1) { $c = 3988292384 -bxor ($c -shr 1) } else { $c = $c -shr 1 }  # 0xEDB88320
    }
    $table[$n] = $c
  }
  [long]$crc = 4294967295
  foreach ($b in $Bytes) { $crc = $table[($crc -bxor $b) -band 255] -bxor ($crc -shr 8) }
  return [uint32]($crc -bxor 4294967295)
}

function Get-Deflated([byte[]]$Bytes) {
  $buf = New-Object IO.MemoryStream
  $deflate = New-Object IO.Compression.DeflateStream($buf, [IO.Compression.CompressionLevel]::Optimal)
  $deflate.Write($Bytes, 0, $Bytes.Length)
  $deflate.Dispose()
  return , $buf.ToArray()
}

function Set-Field([byte[]]$Buf, [int]$At, $Value) {
  $bytes = [BitConverter]::GetBytes($Value)
  [Array]::Copy($bytes, 0, $Buf, $At, $bytes.Length)
}

# Returns the pak's bytes with index.html replaced. Every other entry is copied byte for
# byte; only the offsets after index.html move. (System.IO.Compression's Update mode is
# avoided: it re-encodes every header, and on .NET Framework it corrupts the empty
# deflated entries this pak contains.)
function New-PakBytes([byte[]]$Zip, [string]$Html) {
  $eocd = -1
  for ($i = $Zip.Length - 22; $i -ge [Math]::Max(0, $Zip.Length - 65557); $i--) {
    if ([BitConverter]::ToUInt32($Zip, $i) -eq 0x06054b50) { $eocd = $i; break }
  }
  if ($eocd -lt 0) { throw "frontend.pak is not a readable ZIP." }
  $count = [BitConverter]::ToUInt16($Zip, $eocd + 10)
  [long]$cdSize = [BitConverter]::ToUInt32($Zip, $eocd + 12)
  [long]$cdOff = [BitConverter]::ToUInt32($Zip, $eocd + 16)
  if ($count -eq 0xFFFF -or $cdOff -eq 4294967295 -or [BitConverter]::ToUInt16($Zip, $eocd + 4) -ne 0) {
    throw "frontend.pak is a ZIP64 or multi-volume archive: format not supported, nothing was changed."
  }

  # Central directory: where each entry's record is, and where its local header sits.
  $cd = New-Object byte[] $cdSize
  [Array]::Copy($Zip, $cdOff, $cd, 0, $cdSize)
  $records = New-Object System.Collections.Generic.List[object]
  $p = 0
  for ($n = 0; $n -lt $count; $n++) {
    if ([BitConverter]::ToUInt32($cd, $p) -ne 0x02014b50) { throw 'Unreadable ZIP central directory.' }
    $nameLen = [BitConverter]::ToUInt16($cd, $p + 28)
    $records.Add([pscustomobject]@{
      At = $p
      Name = $Utf8.GetString($cd, $p + 46, $nameLen)
      Offset = [long][BitConverter]::ToUInt32($cd, $p + 42)
    })
    $p += 46 + $nameLen + [BitConverter]::ToUInt16($cd, $p + 30) + [BitConverter]::ToUInt16($cd, $p + 32)
  }
  $found = @($records | Where-Object { $_.Name -ceq 'index.html' })
  if ($found.Count -ne 1) { throw 'index.html not found in the ZIP central directory.' }
  $index = $found[0]
  # index.html's local record runs up to the next local header (or the central directory).
  $start = $index.Offset
  $end = $cdOff
  foreach ($r in $records) { if ($r.Offset -gt $start -and $r.Offset -lt $end) { $end = $r.Offset } }
  if ([BitConverter]::ToUInt32($Zip, $start) -ne 0x04034b50) { throw 'Unreadable local header of index.html.' }

  # New local record: deflated, sizes in the header (no data descriptor), same name and date.
  $raw = $Utf8.GetBytes($Html)
  $data = Get-Deflated $raw
  $crc = Get-Crc32 $raw
  $flags = [uint16]([BitConverter]::ToUInt16($cd, $index.At + 8) -band 0x0800)  # keep the UTF-8 name flag only
  $nameBytes = New-Object byte[] ([BitConverter]::ToUInt16($cd, $index.At + 28))
  [Array]::Copy($cd, $index.At + 46, $nameBytes, 0, $nameBytes.Length)
  $rec = New-Object IO.MemoryStream
  $w = New-Object IO.BinaryWriter($rec)
  $w.Write([uint32]0x04034b50); $w.Write([uint16]20); $w.Write($flags); $w.Write([uint16]8)
  $w.Write([BitConverter]::ToUInt16($cd, $index.At + 12)); $w.Write([BitConverter]::ToUInt16($cd, $index.At + 14))
  $w.Write([uint32]$crc); $w.Write([uint32]$data.Length); $w.Write([uint32]$raw.Length)
  $w.Write([uint16]$nameBytes.Length); $w.Write([uint16]0); $w.Write($nameBytes); $w.Write($data)
  $w.Flush()
  $newRecord = $rec.ToArray()
  $delta = $newRecord.Length - ($end - $start)

  # Central directory: index.html's new fields, then the shifted offsets of what follows it.
  Set-Field $cd ($index.At + 6) ([uint16]20)
  Set-Field $cd ($index.At + 8) $flags
  Set-Field $cd ($index.At + 10) ([uint16]8)
  Set-Field $cd ($index.At + 16) ([uint32]$crc)
  Set-Field $cd ($index.At + 20) ([uint32]$data.Length)
  Set-Field $cd ($index.At + 24) ([uint32]$raw.Length)
  foreach ($r in $records) { if ($r.Offset -gt $start) { Set-Field $cd ($r.At + 42) ([uint32]($r.Offset + $delta)) } }
  $tail = New-Object byte[] ($Zip.Length - $cdOff - $cdSize)
  [Array]::Copy($Zip, $cdOff + $cdSize, $tail, 0, $tail.Length)
  Set-Field $tail ($eocd - $cdOff - $cdSize + 16) ([uint32]($cdOff + $delta))

  $out = New-Object IO.MemoryStream
  $out.Write($Zip, 0, $start)
  $out.Write($newRecord, 0, $newRecord.Length)
  $out.Write($Zip, $end, $cdOff - $end)
  $out.Write($cd, 0, $cd.Length)
  $out.Write($tail, 0, $tail.Length)
  return , $out.ToArray()
}

function Write-Html([string]$Html) {
  $tmp = "$pak.alias-tmp"
  try {
    [IO.File]::WriteAllBytes($tmp, (New-PakBytes ([IO.File]::ReadAllBytes($pak)) $Html))
    Assert-SameEntries $pak $tmp $Html
    Set-Pak $tmp
  } finally {
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
  }
}

function Copy-Verified([string]$From, [string]$To, [string]$Sha) {
  Copy-Item -LiteralPath $From -Destination $To -Force
  if ((Get-FileSha $To) -ne $Sha) { throw "Copy does not match: $To" }
}

# ---- actions -------------------------------------------------------------------

function Show-Status {
  $running = @(Get-RunningLauncher)
  $state = Get-PakState
  $file = Get-Item -LiteralPath $pak
  $pakSha = Get-FileSha $pak
  $launcher = 'closed'
  if ($running.Count) { $launcher = 'RUNNING, close it before install/revert' }
  Say ('Launcher   : Gameforge Client {0}, {1}' -f (Get-LauncherVersion), $launcher)
  Say ('frontend   : {0}' -f $pak)
  Say ('             {0} bytes, {1:yyyy-MM-dd HH:mm}, sha256 {2}' -f $file.Length, $file.LastWriteTime, (Short $pakSha))

  if (-not $state.Installed) {
    Say 'Add-on     : not installed' Yellow
  } elseif (-not $state.Intact) {
    Say 'Add-on     : installed, but the injected code was altered: run install again' Red
  } elseif ((Test-Path -LiteralPath $addon -PathType Leaf) -and $state.AddonSha -eq (Get-Addon)[1]) {
    Say ('Add-on     : installed, identical to {0}' -f $addon) Green
  } else {
    Say ('Add-on     : installed ({0}), differs from {1}: run install to update it' -f (Short $state.AddonSha), $addon) Yellow
  }
  if ($state.Diagnostic) { Say 'Diagnostic : label on (install without -Diagnostic removes it)' Cyan }

  if (Test-Path -LiteralPath $backup) {
    $backupSha = Get-FileSha $backup
    if ($state.Installed -and $backupSha -eq $state.OrigSha) {
      Say ('Backup     : {0} (matches the original)' -f $backup) Green
    } elseif ($state.Installed) {
      Say ('Backup     : {0} does NOT match the original: revert can only remove the block' -f $backup) Red
    } elseif ($backupSha -eq $pakSha) {
      Say ('Backup     : {0} (same as the current pak, revert will delete it)' -f $backup)
    } else {
      Say ('Backup     : {0} outdated (pak replaced since, probably by a launcher update)' -f $backup) Yellow
    }
  } elseif ($state.Installed) {
    Say 'Backup     : MISSING, revert can only remove the block' Red
  } else {
    Say 'Backup     : none'
  }

  if (Test-Path -LiteralPath "$pak.update") {
    Say 'Update     : frontend.pak.update present, a frontend update is in progress or failed' Yellow
  }
  if (-not (Test-CanWrite (Split-Path $pak))) { Say 'Rights     : install and revert will ask for elevation (UAC)' }
}

function Install-Addon {
  $code, $addonSha = Get-Addon
  $state = Get-PakState
  $sameCode = $state.Installed -and $state.Intact -and $state.AddonSha -eq $addonSha
  if ($sameCode -and $state.Diagnostic -eq [bool]$Diagnostic) {
    Say 'Add-on already installed and up to date: nothing to do.' Green
    return
  }
  Assert-Writable
  if ($state.Installed) {
    # Keep the backup taken at first install: it is the untouched original.
    Write-Html (Add-Block (Remove-Block $state.Html) (New-Block $code $addonSha $state.OrigSha))
    if (-not $sameCode) {
      if ($state.AddonSha -eq $addonSha) { Say 'Injected code was altered: add-on injected again.' Green }
      else { Say ('Add-on updated ({0} -> {1}).' -f (Short $state.AddonSha), (Short $addonSha)) Green }
    }
    Show-DiagnosticNote ($state.Diagnostic -and -not $Diagnostic)
    return
  }
  $origSha = Get-FileSha $pak
  if ((Test-Path -LiteralPath $backup) -and (Get-FileSha $backup) -eq $origSha) {
    Say "Backup already present: $backup"
  } else {
    if (Test-Path -LiteralPath $backup) { Say 'Outdated backup replaced (the launcher has updated the pak since).' Yellow }
    Copy-Verified $pak $backup $origSha
    Say "Backup: $backup"
  }
  Write-Html (Add-Block $state.Html (New-Block $code $addonSha $origSha))
  Say 'Add-on installed. In the launcher, game account list: a pencil on every row and the "Alias" bar at the bottom right.' Green
  Show-DiagnosticNote $false
  Say 'To remove it: Uninstall.cmd, or this script with revert.'
}

function Show-DiagnosticNote([bool]$Removed) {
  if ($Diagnostic) {
    Say 'Diagnostic mode: an "alias: ..." label shows at the bottom left of the launcher''s main window (nothing at all = this index.html is not displayed).' Cyan
  } elseif ($Removed) {
    Say 'Diagnostic mode removed.' Green
  }
}

function Undo-Addon {
  $state = Get-PakState
  $hasBackup = Test-Path -LiteralPath $backup
  if (-not $state.Installed -and -not $hasBackup) {
    Say 'Add-on not installed: nothing to do.' Green
    return
  }
  Assert-Writable
  if (-not $state.Installed) {
    # Restoring an older backup over a newer pak would downgrade the launcher UI.
    Remove-Item -LiteralPath $backup -Force
    Say 'Add-on not installed and frontend.pak is the original: the backup, no longer needed, was deleted.' Green
    return
  }
  if ($hasBackup -and (Get-FileSha $backup) -eq $state.OrigSha) {
    $tmp = "$pak.alias-tmp"
    try {
      Copy-Verified $backup $tmp $state.OrigSha
      Set-Pak $tmp
    } finally {
      if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
    }
    Remove-Item -LiteralPath $backup -Force
    Say ('frontend.pak restored byte for byte (sha256 {0}), backup deleted.' -f (Short $state.OrigSha)) Green
    return
  }
  Write-Html (Remove-Block $state.Html)
  Say "Backup missing or not matching: only the add-on's block was removed from index.html." Yellow
  Say 'index.html is the original again, but the archive is not byte for byte: if the next frontend update fails, repair or reinstall the Gameforge Client.' Yellow
}

# ---- main ----------------------------------------------------------------------

try {
  Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
  $pak = Find-Pak
  $backup = "$pak.alias-backup"
  if (-not $AddonPath) { $AddonPath = Join-Path $PSScriptRoot '..\src\alias-addon.js' }
  $addon = [IO.Path]::GetFullPath($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($AddonPath))
  switch ($Action) {
    'status' { Show-Status }
    'install' { Assert-LauncherClosed; Install-Addon }
    'revert' { Assert-LauncherClosed; Undo-Addon }
  }
  exit 0
} catch {
  Say ('ERROR: ' + $_.Exception.Message) Red
  exit 1
}
