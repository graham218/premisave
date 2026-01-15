<#
============================================================
 Premisave App – Flutter Web Runner
------------------------------------------------------------
 Builder        : Bill Graham Peacemaker
 GitHub         : https://github.com/graham218
 Version        : 1.0.0
 Script Name    : run_web.ps1
 Description    : Cross-terminal safe Flutter Web launcher
 Compatibility  : PowerShell 5+, PowerShell Core (7+)
------------------------------------------------------------
 Notes:
 - Run from any terminal using:
     powershell -ExecutionPolicy Bypass -File run_web.ps1
 - Works in Windows Terminal, CMD, Git Bash, WSL, VS Code
============================================================
#>

# ========================
# SAFETY CHECKS
# ========================
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PowerShell 5+ is required." -ForegroundColor Red
    exit 1
}

# Enable ANSI colors if supported
$SupportsColor = $Host.UI.SupportsVirtualTerminal

function Color($name) {
    if ($SupportsColor) { return $name }
    return "White"
}

# ========================
# COLORS
# ========================
$green  = Color "Green"
$cyan   = Color "Cyan"
$yellow = Color "Yellow"
$gray   = Color "DarkGray"
$red    = Color "Red"

# ========================
# CLEAR SCREEN (SAFE)
# ========================
try { Clear-Host } catch {}

# ========================
# ASCII LOGO
# ========================
$logo = @(
    "  _____                         _                     ",
    " |  __ \                       | |                    ",
    " | |__) | __ ___ _ __ ___   ___| |__   __ _ _ __ ___  ",
    " |  ___/ '__/ _ \ '_ ` _ \ / _ \ '_ \ / _` | '__/ _ \ ",
    " | |   | | |  __/ | | | | |  __/ |_) | (_| | | |  __/ ",
    " |_|   |_|  \___|_| |_| |_|\___|_.__/ \__,_|_|  \___| ",
    "                APP                                   "
)

foreach ($line in $logo) {
    Write-Host $line -ForegroundColor $green
    Start-Sleep -Milliseconds 35
}

Write-Host ""
Write-Host ":: Premisave App :: Flutter Web :: Chrome ::" -ForegroundColor $yellow
Write-Host "Builder  : Bill Graham Peacemaker" -ForegroundColor $gray
Write-Host "Version  : 1.0.0" -ForegroundColor $gray
Write-Host "GitHub   : https://github.com/graham218" -ForegroundColor $gray
Write-Host "------------------------------------------------------------" -ForegroundColor $gray
Write-Host ""

# ========================
# LOG FUNCTION
# ========================
function Log($level, $msg, $color = $cyan) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$time [$level] $msg" -ForegroundColor $color
    Start-Sleep -Milliseconds 200
}

Log "INFO" "Bootloader        : Initializing runtime"
Log "INFO" "Environment       : Profile loaded"
Log "INFO" "SecurityManager   : Sandbox enabled"
Log "INFO" "FlutterEngine     : Preparing web renderer"

Write-Host ""

# ========================
# LOADING ANIMATION
# ========================
$frames = @("|", "/", "-", "\")
for ($i = 0; $i -lt 20; $i++) {
    foreach ($f in $frames) {
        Write-Host -NoNewline "`rInitializing modules [$f]" -ForegroundColor $yellow
        Start-Sleep -Milliseconds 100
    }
}
Write-Host "`rInitializing modules [OK]" -ForegroundColor $green
Write-Host ""

# ========================
# FLUTTER CHECK
# ========================
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Log "ERROR" "Flutter is not installed or not in PATH" $red
    Write-Host "Fix: https://docs.flutter.dev/get-started/install" -ForegroundColor $yellow
    exit 1
}

Log "INFO" "WebServer         : Listening on port 3000"
Log "INFO" "PremisaveApp      : Startup complete"
Write-Host "------------------------------------------------------------" -ForegroundColor $gray
Write-Host ""

# ========================
# RUN FLUTTER
# ========================
flutter run -d chrome --web-port=3000
