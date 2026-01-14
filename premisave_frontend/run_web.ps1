# run_web.ps1

Clear-Host

$green  = "Green"
$cyan   = "Cyan"
$yellow = "Yellow"
$gray   = "DarkGray"

# ========================
# ASCII LOGO (SAFE)
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
    Start-Sleep -Milliseconds 40
}

Write-Host ""
Write-Host ":: Premisave App :: Flutter Web :: Chrome ::" -ForegroundColor $yellow
Write-Host "------------------------------------------------------------" -ForegroundColor $gray
Write-Host ""

# ========================
# LOG FUNCTION
# ========================
function Log($level, $msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$time [$level] $msg" -ForegroundColor $cyan
    Start-Sleep -Milliseconds 300
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
foreach ($i in 1..20) {
    foreach ($f in $frames) {
        Write-Host -NoNewline "`rInitializing modules [$f]" -ForegroundColor $yellow
        Start-Sleep -Milliseconds 120
    }
}

Write-Host ""
Write-Host ""

Log "INFO" "WebServer         : Listening on port 3000"
Log "INFO" "PremisaveApp      : Startup complete"
Write-Host "------------------------------------------------------------" -ForegroundColor $gray
Write-Host ""

# ========================
# RUN FLUTTER
# ========================
flutter run -d chrome --web-port=3000
