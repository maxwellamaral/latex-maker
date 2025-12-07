# Build script for Windows PowerShell: uses latexmk with XeLaTeX
param(
    [switch]$clean,
    [switch]$light,
    [switch]$bib,
    [string]$engine = 'xelatex', # xelatex, lualatex, pdflatex
    [switch]$Force,
    [switch]$KeepEnginePdf,
    [string]$FinalizeAs,
    [string]$file = 'exemplo.tex'
)

# Resolve full path
$cwd = Get-Location
# If the file parameter defaults and doesn't exist, try to detect a single tex file
if ($file -eq 'exemplo.tex' -and -not (Test-Path (Join-Path $cwd $file))) {
    $texFiles = Get-ChildItem -Path $cwd -Filter *.tex -File -ErrorAction SilentlyContinue
    if ($texFiles.Count -eq 1) {
        $file = $texFiles[0].Name
        Write-Host "Detected single .tex file in directory: $file" -ForegroundColor Cyan
    }
}
$fullfile = Join-Path $cwd $file

if (-not (Test-Path $fullfile)) {
    Write-Error "File $file not found in $cwd"
    exit 1
}

if ($clean) {
    Write-Host "Cleaning build artifacts (full clean)..."
    # Prefer our PowerShell clean script if present
    $cleanScript = Join-Path $PSScriptRoot "clean.ps1"
    if (Test-Path $cleanScript) {
        & $cleanScript -Full -Force
    } else {
        latexmk -C
    }
    exit 0
}

if ($light) {
    Write-Host "Cleaning build artifacts (light clean)..."
    $cleanScript = Join-Path $PSScriptRoot "clean.ps1"
    if (Test-Path $cleanScript) {
        & $cleanScript -Force
    } else {
        latexmk -c
    }
    exit 0
}

# Determine latexmk engine argument
$engine = $engine.ToLower()
switch ($engine) {
    'xelatex' { $latexmkEngine = '-xelatex' ; $engineName = 'XeLaTeX' }
    'lualatex' { $latexmkEngine = '-lualatex' ; $engineName = 'LuaLaTeX' }
    'pdflatex' { $latexmkEngine = '-pdflatex' ; $engineName = 'pdfLaTeX' }
    default { Write-Warning "Unknown engine '$engine', defaulting to XeLaTeX"; $latexmkEngine = '-xelatex' ; $engineName = 'XeLaTeX' }
}

# Basic sanity check: if the preamble uses fontspec and the user requests pdflatex, warn and abort unless forced
$preamblePath = Join-Path $PWD "styles/preamble.tex"
if (Test-Path $preamblePath) {
    $preambleText = Get-Content -Raw -Path $preamblePath
    if ($preambleText -match "\\usepackage\s*\{fontspec\}" -and $engine -eq 'pdflatex') {
        Write-Host "Warning: preamble uses 'fontspec' which requires XeLaTeX/LuaLaTeX; pdflatex may fail." -ForegroundColor Yellow
        if (-not $Force) {
            Write-Host "Run with -Force to ignore this check or choose another engine: -engine xelatex" -ForegroundColor Yellow
            exit 2
        }
    }
}

Write-Host "Building $file with latexmk ($engineName + BibTeX if needed)"
$latexmkForceArg = ''
if ($Force) { $latexmkForceArg = '-f' }
# Prefer to override what latexmk uses for pdflatex so it does not try to run real pdflatex when engine is xelatex/lualatex
$pdflatexArg = ''
switch ($engine) {
    'xelatex' { $pdflatexArg = '-pdflatex="xelatex -interaction=nonstopmode -halt-on-error -synctex=1 %O %S"' }
    'lualatex' { $pdflatexArg = '-pdflatex="lualatex -interaction=nonstopmode -halt-on-error -synctex=1 %O %S"' }
    'pdflatex' { $pdflatexArg = '' }
}
$cmd = "latexmk $latexmkEngine -pdf $latexmkForceArg $pdflatexArg $file"
Write-Host "Command: $cmd"
Invoke-Expression $cmd

if (!$?) {
    Write-Error "Build failed. Check log for details."
    exit 1
}

# After successful build: optional keep per-engine copy and/or finalize
$outPdf = Join-Path $cwd ($file -replace '\.tex$','.pdf')
if (Test-Path $outPdf) {
    if ($KeepEnginePdf) {
        $enginePdf = Join-Path $cwd (($file -replace '\.tex$') + "." + $engine + ".pdf")
        Copy-Item -Path $outPdf -Destination $enginePdf -Force
        Write-Host "Saved engine-specific copy: $enginePdf"
    }
    if ($FinalizeAs) {
        # FinalizeAs may be an engine name like 'xelatex' or a path to an existing engine suffixed PDF
        $finalEngine = $FinalizeAs.ToLower()
        $candidate = Join-Path $cwd (($file -replace '\.tex$') + "." + $finalEngine + ".pdf")
        if (Test-Path $candidate) {
            Copy-Item -Path $candidate -Destination $outPdf -Force
            Write-Host "Finalized $candidate as $outPdf"
        }
        else {
            Write-Warning "Could not find engine-specific PDF to finalize: $candidate"
        }
    }
}

Write-Host "Build finished. Output: $($file -replace '\.tex$','.pdf')"
