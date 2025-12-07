# latexmk configuration file for this project
# Default to XeLaTeX (uses system fonts via fontspec)
$default_engine = 'xelatex';
# Output in PDF mode
$pdf_mode = 1;
# Files to remove for a light clean with 'latexmk -c'
$clean_ext = 'aux bbl blg brf idx ind ilg lof lot lol out toc synctex.gz fdb_latexmk fls run.xml nav snm vrb';
# Files to remove for a full clean with 'latexmk -C' (includes PDF)
$clean_full_ext = "$clean_ext pdf";
# Use xelatex with good interaction, halt on error and create synctex
# Set xelatex flags and ensure latexmk does not use pdflatex
$xelatex = 'xelatex -interaction=nonstopmode -halt-on-error -synctex=1 %O %S';
# Do not force pdflatex to use xelatex here. Keep default engine as XeLaTeX but
# allow explicit engine selection (e.g. latexmk -pdf -pdflatex) to take effect.
# Make sure bibtex is invoked when needed
$bibtex = 'bibtex %O %S';
# Use the pdflatex fallback if someone calls latexmk without the -xelatex option
$pdf_previewer = 'start';
# Do not generate ps files
# Do not generate PS files by default
$force_mode = 0;
# Keep intermediate files by default disabled (use latexmk -c to clean)
# For safety, allow latexmk -c to remove intermediate files; -C will also remove generated PDF
$cleanup_includes = 1;

# Print progress messages
$silent = 0;
