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
DST_ROOT="/afs/desy.de/user/b/bortolet/code/edm4hep_output"
COPY_ROOT="/afs/desy.de/user/b/bortolet/code/tomaz-example/copied_files"

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
echo "Source folder: $SRC_ROOT"
echo "Output folder: $DST_ROOT"

#mkdir -p "$COPY_ROOT"
#echo "Copied Folder: $COPY_ROOT"
# ------------------------------------------------------------------
# 4  Add patch file
# ------------------------------------------------------------------
PATCH="patch.txt"

# ------------------------------------------------------------------
# 5  Find every *.slcio file (recursively) and process it
# ------------------------------------------------------------------
max_files=5          # stop after we’ve processed this many files
processed=0           # counter

find "$SRC_ROOT" -type f -name '*eR.pL*.slcio' -print0 |
while IFS= read -r -d '' src_file; do
    # Stop once we hit the limit
    (( processed++ ))
    if (( processed > max_files )); then
        echo "Reached the limit of $max_files files – stopping."
        break
    fi

    # --------------------------------------------------------------
    # 1️⃣  Copy the source file to the backup folder
    # --------------------------------------------------------------
    # Preserve the relative directory structure under $COPY_ROOT
    rel_copy_path="${src_file#*${RELATIVE_FROM}/}"
    copy_target="${COPY_ROOT}/${rel_copy_path}"
    #mkdir -p "$(dirname "$copy_target")"
    #cp -a "$src_file" "$copy_target"
    #echo "Copied: $src_file → $copy_target"

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
    echo "Converting ($processed/$max_files): $src_file → $dst_file"
    # Dry‑run line kept for reference – remove/comment out if you don’t need it
    #echo "[DRY‑RUN] Would run: lcio2edm4hep \"$src_file\" \"$dst_file\""

    # Actual conversion
    lcio2edm4hep "$src_file" "$dst_file"
done

#/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/
