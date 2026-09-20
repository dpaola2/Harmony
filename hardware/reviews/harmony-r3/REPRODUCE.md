# Reproducing the R3 checks

Use native KiCad 8.0.9 CLI with an isolated configuration (run_native_checks.py creates it). Run verify_revision.py and physical/inspect_native.py using KiCad's bundled Python 3.9 with pcbnew/wx, then run verify_symbols.py with Python 3.

The analytic geometry checks use Shapely 2.1.2, pinned in requirements-geometry.txt. The review used Python 3.14 in /tmp/harmony-geometry-venv; that temporary environment is not part of the deliverable. Create an isolated environment and install the requirements to rerun physical/check_isolation.py, physical/verify_source_delta.py and physical/review_jack_scope.py. Root reran electrode isolation and zone-delta checks independently after the agent froze its files.

Regenerate the quote with generate_quote_package.py only after copying the latest four ERC/DRC reports into assembly-quote-r3. Run its validator and reviews/harmony-r3/verify_quote_package.py. Native errors deliberately remain; exit code 5 is a findings result, not a fabrication release.

apply_jack_fix.py documents the original board mutation from the R2 copy and relies on preserved experiment fill output. sync_jack_library.py is the necessary next step using KiCad Python; it exports the authoritative board footprint to unflipped library coordinates. These mutation scripts are provenance, not checks to run on a released design.

The mainboard-experiment and physical/sliver-localization folders contain unreleased experiments. Fabrication exports for current engineering review are only under hardware/procurement/assembly-quote-r3/fabrication.
