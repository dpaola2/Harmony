# Design review record

September 13, 2026. HARMONY-8.

The package is intended to support a platform decision and a first enclosure fit print. It includes all printed enclosure components for the proposed Tangara-based player, reference electronics, and assembly requirements. It does not claim a working Harmony firmware build or verified hardware performance.

The mechanical review found three upstream-version mismatches: the touch cover intersected the front retainer, the older lens extended into the newer shell, and the sprung cage overlapped the reference battery envelope. The revised circular cover has a matching recess; a smaller 0.5 mm lens clears the shell; passive guides clear the battery. The final generator requires zero material intersections among printed parts and between the checked references and their surrounding parts.

The rear-shell tessellation also contained duplicate vertices at tangent fillets. Welding vertices at 0.1 micron and removing collapsed or duplicate triangles resolved the non-manifold mesh without changing the CAD solid or filling mesh holes. All released print meshes must be closed, consistently wound, positive-volume solids before export.

The writing reference was Dave's `2021-10-27-leakaware-product-process.txt`: a direct recommendation tied to product goals, followed by working agreements. The first draft was too long for that memo register, so the detailed architecture, comparison, and acceptance material moved to a separate technical note. The recommendation is 399 words. That is slightly above the corpus maximum of 379 because it includes source links, scope, and artifact navigation. Its longer paragraphs and lower sentence-length variance are deliberate costs of a short factual design recommendation; adding personal asides to match the corpus would invent a voice the sources do not support.

Critique intent: make the proposed hardware direction assessable without implying it is adopted or proven. The recommendation succeeds where it ties deferred Bluetooth and battery work to Dave's actual brief. The initial technical detail obscured that decision and was separated. The mechanical revision narrative remains in this review record so it does not dominate the recommendation. The wording audit found no remaining detector issues in the recommendation or technical basis; an internal-ledge description was tightened in the print guide. Manual rubric: directness 9, rhythm 8, trust 9, authenticity 8, density 9 (43/50).

Open physical checks are explicit: selected PCB/display/battery dimensions, printer tolerance, retention and button return, touch sensitivity, charge behavior, battery cutoff and runtime, and pocket Bluetooth reception. BOM availability and a compatible firmware pair remain procurement and bring-up work.
