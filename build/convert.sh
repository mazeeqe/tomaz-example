#!/usr/bin/env bash
# -------------------------------------------------
# Convert every *.slcio file under $SRC_ROOT
# to *.edm4hep.root files under $DST_ROOT,
# preserving the directory hierarchy **starting at
# the 250-SetA folder** (i.e. everything below it).
# -------------------------------------------------

# ------------------------------------------------------------------
# 1️⃣  Configuration – change these two lines for your own paths
# ------------------------------------------------------------------
SRC_ROOT="/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/4f_WW_semileptonic/"          # <-- change this
DST_ROOT="/afs/desy.de/user/b/bortolet/code/edm4hep_output" # <-- change this

# ------------------------------------------------------------------
# 2️⃣  Define the point in the source tree where we want to start
#     copying the relative layout. Everything before this string
#     will be stripped from the path.
# ------------------------------------------------------------------
RELATIVE_FROM="250-SetA"          # <-- stop stripping here

# ------------------------------------------------------------------
# 3️⃣  Make sure the destination root exists
# ------------------------------------------------------------------
mkdir -p "$DST_ROOT"

# ------------------------------------------------------------------
# 4️⃣  Find every *.slcio file (recursively) and process it
# ------------------------------------------------------------------
find "$SRC_ROOT" -type f -name '*.slcio' -print0 |
while IFS= read -r -d '' src_file; do
    # --------------------------------------------------------------
    # Strip everything up to (and including) the chosen anchor folder
    # Example:
    #   src_file = /pnfs/.../dst-merged/250-SetA/4f_WW_semileptonic/sub/a.slcio
    #   rel_path = 4f_WW_semileptonic/sub/a.slcio
    # --------------------------------------------------------------
    rel_path="${src_file#*${RELATIVE_FROM}/}"

    # Build the destination filename, swapping the extension
    dst_file="${DST_ROOT}/${rel_path%.slcio}.edm4hep.root"

    # Ensure the destination directory exists before conversion
    mkdir -p "$(dirname "$dst_file")"

    # --------------------------------------------------------------
    # 5️⃣  Run the conversion command
    # --------------------------------------------------------------
    echo "Converting: $src_file → $dst_file"
    echo "[DRY‑RUN] Would run: lcio2edm4hep \"$src_file\" \"$dst_file\""
    #lcio2edm4hep "$src_file" "$dst_file"

done

#/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/