#Requires -Version 5
<#
.SYNOPSIS
  Awesome CC Statusline installer for Windows (PowerShell).

.DESCRIPTION
  1. Ensures `jq` is installed (auto via winget/scoop/choco).
  2. Ensures Git Bash exists (installs Git via winget if missing) so Claude Code
     can run the bash statusline script on Windows.
  3. Copies the chosen size script to ~/.claude/awesome-statusline.sh
  4. Patches settings.json -> statusLine (existing settings preserved + backup).

.EXAMPLE
  ./install.ps1            # interactive picker
  ./install.ps1 xl         # by abbreviation
  ./install.ps1 xlarge     # by full name
#>
param([string]$Size)

$ErrorActionPreference = 'Stop'

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
$Dest      = Join-Path $ClaudeDir 'awesome-statusline.sh'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir    = Join-Path $ScriptDir 'scripts'
$RepoRaw   = if ($env:AWESOME_STATUSLINE_RAW) { $env:AWESOME_STATUSLINE_RAW } else { 'https://raw.githubusercontent.com/AwesomeJun/CC-statusline/main' }

# --- dependency installer ---------------------------------------------------
function Ensure-Tool([string]$Cmd, [string]$WingetId, [string]$ScoopPkg, [string]$ChocoPkg) {
  if (Get-Command $Cmd -ErrorAction SilentlyContinue) { return }
  Write-Info "$Cmd not found - installing..."
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --silent --accept-package-agreements --accept-source-agreements -e --id $WingetId
  } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
    scoop install $ScoopPkg
  } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    choco install $ChocoPkg -y
  } else {
    Write-Err "No package manager (winget/scoop/choco) found. Please install $Cmd manually."
    exit 1
  }
}

function Test-GitBash {
  if (Get-Command bash -ErrorAction SilentlyContinue) { return $true }
  foreach ($p in @("$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe")) {
    if (Test-Path $p) { return $true }
  }
  return $false
}

# --- pick size --------------------------------------------------------------
$Mode = $null
if ($Size) {
  $Mode = Normalize-Mode $Size
  if (-not $Mode) {
    Write-Err "Unknown size: '$Size'"
    Write-Err "Valid: xsmall|xs  small|s  medium|m  large|l  xlarge|xl"
    exit 1
  }
} else {
  Write-Host "Select a statusline size:"
  Write-Host "  1) xsmall (xs)  2 lines  - minimal"
  Write-Host "  2) small  (s)   2 lines  - labels + %"
  Write-Host "  3) medium (m)   4 lines  - classic"
  Write-Host "  4) large  (l)   5 lines  - 20-block bars"
  Write-Host "  5) xlarge (xl)  5 lines  - full detail"
  $choice = Read-Host "Choice [1-5] (default 5)"
  switch ($choice) {
    '1' { $Mode = 'xsmall' }
    '2' { $Mode = 'small' }
    '3' { $Mode = 'medium' }
    '4' { $Mode = 'large' }
    default { $Mode = 'xlarge' }
  }
}

# --- ensure dependencies ----------------------------------------------------
Ensure-Tool -Cmd 'jq' -WingetId 'jqlang.jq' -ScoopPkg 'jq' -ChocoPkg 'jq'
if (-not (Test-GitBash)) {
  Write-Info "Git Bash not found - installing Git (provides bash to run the statusline)..."
  Ensure-Tool -Cmd 'git' -WingetId 'Git.Git' -ScoopPkg 'git' -ChocoPkg 'git'
}

# --- install the script -----------------------------------------------------
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
$Src = Join-Path $SrcDir "awesome-statusline-$Mode.sh"
if (Test-Path $Src) {
  Copy-Item $Src $Dest -Force
} else {
  Write-Info "Local scripts/ not found, downloading size '$Mode' from repo..."
  Invoke-WebRequest -Uri "$RepoRaw/scripts/awesome-statusline-$Mode.sh" -OutFile $Dest
}

# --- patch settings.json ----------------------------------------------------
$slObj = [pscustomobject]@{ type = 'command'; command = '~/.claude/awesome-statusline.sh' }
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
Write-Host ""
Write-Host "Change size later:  ./install.ps1 <xsmall|small|medium|large|xlarge>  (or xs/s/m/l/xl)"
Write-Host "Restart Claude Code to see it."
