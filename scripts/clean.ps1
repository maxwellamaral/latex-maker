<#
scripts/clean.ps1
PowerShell script to clean LaTeX build artifacts in the project root.

Usage:
  .\scripts\clean.ps1            # performs a light clean (removes intermediate files; keeps PDFs)
  .\scripts\clean.ps1 -Full     # performs a full clean (also removes PDF output)
  .\scripts\clean.ps1 -Force    # no confirmation prompt

This script attempts to use latexmk -c or latexmk -C when available, otherwise
it falls back to deleting known intermediate extensions.
#>

param (
    [switch]$Full,
    [switch]$Force
)

# Resolve project root as parent of this script
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$projectRoot = Resolve-Path (Join-Path $scriptDir "..")
Set-Location $projectRoot

function Remove-Patterns {
    param(
        [string[]]$patterns,
        [switch]$whatIf
    )
    foreach ($pattern in $patterns) {
        $matches = Get-ChildItem -Path $pattern -File -ErrorAction SilentlyContinue
        foreach ($f in $matches) {
            if ($whatIf) {
                Write-Host "Would remove: $($f.FullName)"
            }
            else {
                try {
                    Remove-Item -Path $f.FullName -Force -ErrorAction Stop
                    Write-Host "Removed: $($f.FullName)"
                }
                catch {
                    Write-Warning "Failed to remove $($f.FullName): $_"
                }
            }
        }
    }
}

# If latexmk is available, prefer its cleanup functionality
$latexmkExists = Get-Command latexmk -ErrorAction SilentlyContinue
if ($latexmkExists) {
    if ($Full) {
        Write-Host "Running 'latexmk -C' (full clean)"
        & latexmk -C
        if ($LASTEXITCODE -eq 0) { Write-Host "latexmk -C completed." }
        else { Write-Warning "latexmk -C returned code $LASTEXITCODE" }
    }
    else {
        Write-Host "Running 'latexmk -c' (light clean)"
        & latexmk -c
        if ($LASTEXITCODE -eq 0) { Write-Host "latexmk -c completed." }
        else { Write-Warning "latexmk -c returned code $LASTEXITCODE" }
    }
    # latexmk does the job; still try to remove any leftovers below if present
}

# Known extensions and files to remove
$lightPatterns = @("*.aux", "*.log", "*.out", "*.toc", "*.lof", "*.lot", "*.lol", "*.fls", "*.fdb_latexmk", "*.synctex.gz", "*.bbl", "*.blg", "*.run.xml", "*.nav", "*.snm", "*.vrb", "missfont.log")
$fullPatterns = @("*.pdf")

# Prepare deletion list
$toDelete = @()
$toDelete += $lightPatterns
if ($Full) { $toDelete += $fullPatterns }

# Show confirmation
if (-not $Force) {
    Write-Host "About to remove files matching the following patterns in ${projectRoot}:" -ForegroundColor Yellow
    Write-Host ($toDelete -join ', ')
    $response = Read-Host "Type Y to continue, anything else to cancel"
    if ($response -ne 'Y' -and $response -ne 'y') {
        Write-Host "Aborting clean." -ForegroundColor Yellow
        exit 0
    }
}

# Delete matching files
Remove-Patterns -patterns $toDelete

Write-Host "Clean completed." -ForegroundColor Green
