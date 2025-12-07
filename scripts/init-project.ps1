<#
Create a new LaTeX project with the standard structure used in this repository.
Usage:
    .\scripts\init-project.ps1 -Name ProjectName [-Path .] [-Force] [-DefaultEngine xelatex|lualatex|pdflatex] [-CopyImages]

It creates:
  ProjectName/
    ProjectName.tex (main file)
    styles/preamble.tex
    chapters/01-intro.tex
    bib/referencias.bib
    figures/
    scripts/build.ps1 (copied)
    scripts/clean.ps1 (copied)
    latexmkrc (copied)
    README.md (basic)

#>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Name,

    [string]$Path = '.',

    [switch]$Force,
    [switch]$CopyImages,
    [string]$DefaultEngine = 'xelatex'
)

# Resolve root folder for templates (assumes script is under scripts/)
$scriptRoot = Split-Path -Parent $PSScriptRoot

# Sanitize name
$Name = $Name.Trim()
$Name = $Name -replace '[\/:*?"<>| ]', '-' # replace illegal path chars and spaces by -

# Project directory
$projectDir = Join-Path -Path (Resolve-Path -LiteralPath $Path) -ChildPath $Name

if (Test-Path $projectDir) {
    if (-not $Force) {
        Write-Error "Project directory '$projectDir' already exists. Use -Force to overwrite."
        exit 1
    }
    else {
        Write-Host "Removing existing directory: $projectDir" -ForegroundColor Yellow
        Remove-Item -LiteralPath $projectDir -Force -Recurse
    }
}

# Create directory structure
$subdirs = @('chapters','styles','bib','figures','scripts')
New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
foreach ($d in $subdirs) { New-Item -ItemType Directory -Path (Join-Path $projectDir $d) -Force | Out-Null }

# Copy template files if present
function CopyIfExists($srcRelPath, $destRelPath) {
    $src = Join-Path $scriptRoot $srcRelPath
    $dest = Join-Path $projectDir $destRelPath
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dest -Force
        Write-Host "Copied: $srcRelPath -> $destRelPath"
    }
}

# If the user requested a default engine (default 'xelatex'), update project latexmkrc and build script to reflect it
function Set-DefaultEngineForProject($engine, $projectDir) {
    $engine = $engine.ToLower()
    if ($engine -notin @('xelatex','lualatex','pdflatex')) {
        Write-Warning "Unknown engine '$engine'; defaulting to xelatex"
        $engine = 'xelatex'
    }
    # Update latexmkrc in project if exists
    $projectLatexmkrc = Join-Path $projectDir 'latexmkrc'
    if (Test-Path $projectLatexmkrc) {
        $lines = Get-Content -Path $projectLatexmkrc -Encoding UTF8
        $found = $false
        for ($j=0; $j -lt $lines.Count; $j++) {
            if ($lines[$j] -match '^[\s]*\$default_engine\s*=') {
                # Replace entire line with our chosen engine
                $lines[$j] = "`$default_engine = '$engine';"
                $found = $true
            }
        }
        if (-not $found) {
            $lines = @("`$default_engine = '$engine';") + $lines
        }
        Set-Content -Path $projectLatexmkrc -Value $lines -Encoding UTF8
        Write-Host "Set default engine in latexmkrc to: $engine"
    }

    # Update build.ps1 in project if exists (set default engine in param)
    $projBuildScript = Join-Path $projectDir 'scripts\build.ps1'
    if (Test-Path $projBuildScript) {
        $lines = Get-Content -Path $projBuildScript -Encoding UTF8
        for ($i=0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -match '^[\s]*\[string\]\$engine\s*=') {
                # Replace the quoted engine string on this line with the selected engine
                $lines[$i] = $lines[$i] -replace "'[^']+'", "'$engine'"
                break
            }
        }
        Set-Content -Path $projBuildScript -Value $lines -Encoding UTF8
        Write-Host "Set default engine in scripts/build.ps1 to: $engine"
    }
}

CopyIfExists 'styles\preamble.tex' 'styles\preamble.tex'
CopyIfExists 'chapters\01-intro.tex' 'chapters\01-intro.tex'
CopyIfExists 'chapters\00-pre-text.tex' 'chapters\00-pre-text.tex'
CopyIfExists 'bib\referencias.bib' 'bib\referencias.bib'
CopyIfExists 'scripts\build.ps1' 'scripts\build.ps1'
CopyIfExists 'scripts\clean.ps1' 'scripts\clean.ps1'
CopyIfExists 'latexmkrc' 'latexmkrc'
CopyIfExists 'README.md' 'README.md'
Set-DefaultEngineForProject -engine $DefaultEngine -projectDir $projectDir

# Add a short note to README about the chosen default engine (append to README even if it was copied)
$readmePath = Join-Path $projectDir 'README.md'
if (Test-Path $readmePath) {
    $note = "`n`nDefault build engine: $DefaultEngine`nTo override: .\scripts\build.ps1 -engine xelatex|lualatex|pdflatex`n"
    Add-Content -Path $readmePath -Value $note -Encoding UTF8
}

# If the user requested a default engine (default 'xelatex'), update project latexmkrc and build script to reflect it
function Set-DefaultEngineForProject($engine, $projectDir) {
    $engine = $engine.ToLower()
    if ($engine -notin @('xelatex','lualatex','pdflatex')) {
        Write-Warning "Unknown engine '$engine'; defaulting to xelatex"
        $engine = 'xelatex'
    }
    # Update latexmkrc in project if exists (line-by-line replacement)
    $projectLatexmkrc = Join-Path $projectDir 'latexmkrc'
    if (Test-Path $projectLatexmkrc) {
        $lines = Get-Content -Path $projectLatexmkrc -Encoding UTF8
        $foundLine = $false
        for ($j=0; $j -lt $lines.Count; $j++) {
            if ($lines[$j] -match '^[\s]*\$default_engine\s*=') {
                $lines[$j] = "`$default_engine = '$engine';"
                $foundLine = $true
            }
        }
        if (-not $foundLine) {
            $lines = @("`$default_engine = '$engine';") + $lines
        }
        Set-Content -Path $projectLatexmkrc -Value $lines -Encoding UTF8
        Write-Host "Set default engine in latexmkrc to: $engine"
    }

    # Update build.ps1 in project if exists (set default engine in param)
    $projBuildScript = Join-Path $projectDir 'scripts\build.ps1'
    if (Test-Path $projBuildScript) {
        $lines = Get-Content -Path $projBuildScript -Encoding UTF8
        for ($j=0; $j -lt $lines.Count; $j++) {
            if ($lines[$j] -match '^[\s]*\[string\]\$engine\s*=') {
                $lines[$j] = $lines[$j] -replace "'[^']+'", "'$engine'"
                break
            }
        }
        Set-Content -Path $projBuildScript -Value $lines -Encoding UTF8
        Write-Host "Set default engine in scripts/build.ps1 to: $engine"
    }
}

# Generate the main tex file
$mainTexPath = Join-Path $projectDir ("$Name.tex")
$mainTexLines = @(
    "% $Name - generated by init-project.ps1",
    "\input{styles/preamble.tex}",
    "\title{$Name}",
    "\author{Author Name}",
    "\date{\today}",
    "\begin{document}",
    "\maketitle",
    "\input{chapters/01-intro.tex}",
    "",
    "\bibliographystyle{plainnat}",
    "\bibliography{bib/referencias}",
    "\end{document}"
)
$mainTexContent = $mainTexLines -join "`n"
Set-Content -Path $mainTexPath -Value $mainTexContent -Encoding UTF8
Write-Host "Created main file: $($mainTexPath)"

# Create default README (if not copied)
$readmePath = Join-Path $projectDir 'README.md'
if (-not (Test-Path $readmePath)) {
    $readmeContent = @"
# $Name

Projeto LaTeX gerado automaticamente pelo `init-project.ps1`.

## Como compilar
- XeLaTeX (recomendado):
  ```powershell
  .\scripts\build.ps1 -engine xelatex
  ```

- LuaLaTeX:
  ```powershell
  .\scripts\build.ps1 -engine lualatex
  ```

- PDFlatex (não recomendado se usar `fontspec`):
  ```powershell
  .\scripts\build.ps1 -engine pdflatex -Force
  ```

"@
    # Append default engine note
    $readmeContent += "`n`nDefault build engine: $DefaultEngine`nYou can override with: `n  .\scripts\build.ps1 -engine xelatex`n"
    Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
    Write-Host "Created README.md"
}

    # Optionally copy example images from the template figures/ folder if present
    if ($CopyImages) {
        $srcFig = Join-Path $scriptRoot 'figures'
        $destFig = Join-Path $projectDir 'figures'
        if (Test-Path $srcFig) {
            Copy-Item -Path (Join-Path $srcFig '*') -Destination $destFig -Force -Recurse
            Write-Host "Copied example images from template figures/ to project figures/"
        }
    }

# Write a quick .gitignore
$gitIgnorePath = Join-Path $projectDir '.gitignore'
if (-not (Test-Path $gitIgnorePath)) {
    $gitignoreContent = @"
# Ignore build artifacts
*.aux
*.bbl
*.blg
*.log
*.out
*.toc
*.synctex.gz
*.fdb_latexmk
*.fls
*~
"@
    Set-Content -Path $gitIgnorePath -Value $gitignoreContent -Encoding UTF8
    Write-Host "Created .gitignore"
}

Write-Host "Project $Name created at $projectDir" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  cd $projectDir" -ForegroundColor Cyan
Write-Host "  .\scripts\build.ps1 -engine xelatex" -ForegroundColor Cyan

# Return the created path
Write-Output $projectDir
