#!/usr/bin/env bash
# -------------------------------------------------
# Convert all *.slcio files under $SRC_ROOT
# to *.edm4hep.root files under $DST_ROOT,
# preserving the relative directory layout.
# -------------------------------------------------

# 1️⃣  Set the source and destination roots
SRC_ROOT="/path/to/your/slcio_folder"          # <-- change this
DST_ROOT="/path/to/your/edm4hep_output_folder" # <-- change this

# 2️⃣  Create the destination root if it does not exist
mkdir -p "$DST_ROOT"

# 3️⃣  Walk through every .slcio file
find "$SRC_ROOT" -type f -name '*.slcio' | while read -r src_file; do
    # Compute the path relative to the source root
    rel_path="${src_file#$SRC_ROOT/}"               # e.g. subdir/a.slcio

    # Build the matching destination path (replace extension)
    dst_file="${DST_ROOT}/${rel_path%.slcio}.edm4hep.root"

    # Ensure the destination directory exists
    mkdir -p "$(dirname "$dst_file")"

    # Run the conversion command
    echo "Converting: $src_file → $dst_file"
    lcio2edm4hep "$src_file" "$dst_file"
done

#/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/