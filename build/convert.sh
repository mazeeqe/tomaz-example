#!/usr/bin/env bash
# -------------------------------------------------
# Convert every *.slcio file under $SRC_ROOT
# to *.edm4hep.root files under $DST_ROOT,
# preserving the original directory hierarchy.
# -------------------------------------------------

# ------------------------------------------------------------------
# 1️⃣  Configuration – change these two lines for your own paths
# ------------------------------------------------------------------
SRC_ROOT="/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/4f_WW_semileptonic/"          # <-- change this
DST_ROOT="/afs/desy.de/user/b/bortolet/code/edm4hep_output" # <-- change this

# ------------------------------------------------------------------
# 2️⃣  Make sure the destination root exists
# ------------------------------------------------------------------
mkdir -p "$DST_ROOT"

# ------------------------------------------------------------------
# 3️⃣  Find every *.slcio file (recursively) and process it
# ------------------------------------------------------------------
#   * -type f   – only regular files
#   * -name '*.slcio' – match the extension
#   * -print0  – NUL‑terminate each result so we can safely handle
#                filenames containing spaces, newlines, etc.
#
# The while‑read loop reads those NUL‑separated names verbatim.
# ------------------------------------------------------------------
find "$SRC_ROOT" -type f -name '*.slcio' -print0 |
while IFS= read -r -d '' src_file; do
    # Strip the source‑root prefix (including the trailing slash)
    rel_path="${src_file#$SRC_ROOT/}"

    # Build the destination filename, swapping the extension
    dst_file="${DST_ROOT}/${rel_path%.slcio}.edm4hep.root"

    # Ensure the destination directory exists before we invoke the converter
    mkdir -p "$(dirname "$dst_file")"

    # ------------------------------------------------------------------
    # 4️⃣  Run the conversion command
    # ------------------------------------------------------------------
    echo "Converting: $src_file → $dst_file"
    echo "[DRY‑RUN] Would run: lcio2edm4hep \"$src_file\" \"$dst_file\""
    #lcio2edm4hep "$src_file" "$dst_file"
done

#/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/