#Requires -Version 5
<#
.SYNOPSIS
  Awesome CC Statusline installer for Windows (PowerShell).

.DESCRIPTION
  1. Copies the native Windows PowerShell renderer to ~/.claude/awesome-statusline.ps1.
  2. Patches settings.json -> statusLine (existing settings preserved + backup).
  3. Uses Claude Code's official statusLine.command contract: JSON on stdin,
     rendered status text on stdout.

.EXAMPLE
  ./install.ps1            # install
  ./install.ps1 l          # by abbreviation
  ./install.ps1 large      # by full name
#>
param([string]$Size)

$ErrorActionPreference = 'Stop'
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

function Write-Info($m) { Write-Host $m -ForegroundColor Cyan }
function Write-Ok($m)   { Write-Host $m -ForegroundColor Green }
function Write-Err($m)  { Write-Host $m -ForegroundColor Red }

function Normalize-Mode([string]$s) {
  switch ($s.ToLower()) {
    'xs'     { 'xsmall' } 'xsmall' { 'xsmall' }
    's'      { 'small' }  'small'  { 'small' }
    'm'      { 'medium' } 'medium' { 'medium' }
    'l'      { 'large' }  'large'  { 'large' }
    'xl'     { 'xlarge' } 'xlarge' { 'xlarge' }
    default  { $null }
  }
}

# --- paths ------------------------------------------------------------------
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$Settings  = Join-Path $ClaudeDir 'settings.json'
$Dest      = Join-Path $ClaudeDir 'awesome-statusline.ps1'
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = if ($ScriptPath) { Split-Path -Parent $ScriptPath } else { (Get-Location).Path }
$SrcDir    = Join-Path $ScriptDir 'scripts'
$RepoRaw   = if ($env:AWESOME_STATUSLINE_RAW) { $env:AWESOME_STATUSLINE_RAW } else { 'https://raw.githubusercontent.com/AwesomeJun/CC-statusline/main' }

# --- pick size --------------------------------------------------------------
# Precedence: explicit argument > interactive prompt > 'large' default.
# When no size is given and a real console is attached, ask (default large).
# In non-interactive contexts (e.g. `irm ... | iex`, CI) we never block — the
# input-redirection guard falls straight through to 'large'.
$Mode = 'large'
if ($Size) {
  $Mode = Normalize-Mode $Size
  if (-not $Mode) {
    Write-Err "Unknown size: '$Size'"
    Write-Err "Valid: xsmall|xs  small|s  medium|m  large|l  xlarge|xl"
    exit 1
  }
} elseif ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
  Write-Host ""
  Write-Host "Choose a status line size preset:"
  Write-Host "  xsmall | small | medium | large | xlarge   (or xs/s/m/l/xl)"
  Write-Host "  Rendered examples: https://github.com/AwesomeJun/CC-statusline"
  $answer = Read-Host "Size [default: large]"
  if (-not [string]::IsNullOrWhiteSpace($answer)) {
    $Mode = Normalize-Mode $answer
    if (-not $Mode) {
      Write-Host "Unknown size '$answer', using 'large'."
      $Mode = 'large'
    }
  }
}

# --- install the script -----------------------------------------------------
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
$Src = Join-Path $SrcDir 'awesome-statusline-windows.ps1'
if (Test-Path $Src) {
  Copy-Item $Src $Dest -Force
} else {
  Write-Info "Local scripts/ not found, downloading Windows renderer from repo..."
  Invoke-WebRequest -Uri "$RepoRaw/scripts/awesome-statusline-windows.ps1" -OutFile $Dest
}

# Force UTF-8 *with* BOM. The renderer body contains non-ASCII glyphs
# (progress-bar blocks U+2588/U+2591, emoji). Windows PowerShell 5.1 does not
# auto-detect UTF-8: with no BOM it reads .ps1 files using the system ANSI code
# page (e.g. CP949 on Korean systems), corrupting those bytes into garbage
# tokens that break the parser and leave the status line blank. Writing the BOM
# explicitly guarantees correct parsing on every host (PS 5.1 and 7+).
$scriptText = [System.IO.File]::ReadAllText($Dest, [System.Text.UTF8Encoding]::new($false))
$utf8Bom = [System.Text.UTF8Encoding]::new($true)
[System.IO.File]::WriteAllText($Dest, $scriptText, $utf8Bom)

# --- patch settings.json ----------------------------------------------------
$CommandPath = $Dest.Replace('\', '/')
$Command = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$CommandPath`" -Size $Mode"
$slObj = [pscustomobject]@{ type = 'command'; command = $Command }
if (Test-Path $Settings) {
  $backup = "$Settings.backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
  Copy-Item $Settings $backup -Force
  $json = Get-Content $Settings -Raw | ConvertFrom-Json
  if ($json.PSObject.Properties.Name -contains 'statusLine') {
    $json.statusLine = $slObj
  } else {
    $json | Add-Member -NotePropertyName 'statusLine' -NotePropertyValue $slObj
  }
  $json | ConvertTo-Json -Depth 20 | Set-Content $Settings -Encoding UTF8
  Write-Info "Existing settings backed up to: $backup"
} else {
  [pscustomobject]@{ statusLine = $slObj } | ConvertTo-Json -Depth 20 | Set-Content $Settings -Encoding UTF8
}

Write-Ok "Installed Awesome CC Statusline (size: $Mode)"
Write-Host "  script:   $Dest"
Write-Host "  settings: $Settings  (statusLine set)"
Write-Host "  command:  $Command"
Write-Host ""
Write-Host "Change size later:  ./install.ps1 <xsmall|small|medium|large|xlarge>  (or xs/s/m/l/xl)"
Write-Host "Restart Claude Code to see it."
