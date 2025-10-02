#!/usr/bin/env bash
set -euo pipefail   # safety: exit on error, treat unset vars as errors

# File Options
SIGNAL="signal"
BACKGROUND="background"


# ---- 2. Define source & destination -----------------------------------------
# The Python script creates a file called "output.txt" in the current directory.
SRC="./hist.root"

# Desired new name and target directory (change as you wish)
NEW_NAME="hist.root"
DEST_DIR="../output_files"

# Build the full destination path
DEST="${DEST_DIR}/${NEW_NAME}"



run_python() {
    # ---- Configuration (edit once) ---------------------------------
    local COMMAND="k4run"                     # interpreter to use
    local SCRIPT_PATH="../example/options/run_example.py" # absolute/relative path
    # -----------------------------------------------------------------

    # The caller supplies everything after the function name as a single
    # string of options.  We keep it in a variable so we can expand it safely.
    local OPTIONS="$*"

    # Execute the command – quoting the interpreter and script protects
    # against spaces in their paths.
    "$COMMAND" "$SCRIPT_PATH" "--$OPTIONS"

    # Capture the exit status if you need it downstream
    local EXIT_CODE=$?
    if (( EXIT_CODE != 0 )); then
        echo "❌ Python script exited with code $EXIT_CODE"
    else
        echo "✅ Python script finished successfully"
    fi
}

transfer_file() {
    local OPTIONS="$*"
    DEST="${DEST_DIR}/${OPTIONS}_hist.root"
    # ---- 3. Make sure the destination directory exists ---------------------------
    if [[ ! -d "${DEST_DIR}" ]]; then
        echo "Creating destination folder: ${DEST_DIR}"
        mkdir -p "${DEST_DIR}"
    fi

    # ---- 5. Move (or rename) the file --------------------------------------------
    if [[ -f "${SRC}" ]]; then
        mv "${SRC}" "${DEST}"
        echo "✅ Moved '${SRC}' → '${DEST}'"
    else
        echo "❌ Source file '${SRC}' not found. Did the Python script run correctly?"
        exit 1
    fi
}

# Run for the signal files
run_python "$SIGNAL"
transfer_file "$SIGNAL"

# Now for the Background files
run_python "$BACKGROUND"
transfer_file "$BACKGROUND"