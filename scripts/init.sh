#!/usr/bin/env bash
set -u
set -o pipefail
# ⚠️ No exit, no set -e (SSH-safe)

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

    # Create a timestamp: 20251027_143210 (YYYYMMDD_HHMMSS)
    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    # Build the destination path with the timestamp inserted before the suffix
    DEST="${DEST_DIR}/${OPTIONS}_${TIMESTAMP}_hist.root"

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
        #exit 1
    fi
}


# ------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------
COMMAND="k4run"
SCRIPT_PATH="../example/options/run_example.py"

DATASET_BASE_DIR="/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA"

SRC="./hist.root"
BASE_OUT_DIR="../output_files"
BASE_LOG_DIR="../logs"

TIMESTAMP_GLOBAL=$(date +%Y%m%d_%H%M%S)

# ------------------------------------------------------------------
# Logging helper (dataset-local)
# ------------------------------------------------------------------
log() {
    local LOGFILE="$1"
    shift
    echo "[$(date '+%F %T')] $*" | tee -a "${LOGFILE}"
}

# ------------------------------------------------------------------
# Run one dataset
# ------------------------------------------------------------------
run_dataset() {
    local DATASET="$1"
    local LOGFILE="$2"

    log "${LOGFILE}" "=============================================="
    log "${LOGFILE}" "Starting dataset: ${DATASET}"

    # ---- Run simulation -------------------------------------------
    "${COMMAND}" "${SCRIPT_PATH}" "--${DATASET}" >>"${LOGFILE}" 2>&1
    local RUN_STATUS=$?

    if (( RUN_STATUS != 0 )); then
        log "${LOGFILE}" "ERROR: Simulation failed (exit code ${RUN_STATUS})"
        return 0
    fi

    log "${LOGFILE}" "Simulation finished successfully"

    # ---- Move output ----------------------------------------------
    local DATASET_OUT_DIR="${BASE_OUT_DIR}/${DATASET}"
    local DEST_FILE="${DATASET}_${TIMESTAMP_GLOBAL}_hist.root"
    local DEST_PATH="${DATASET_OUT_DIR}/${DEST_FILE}"

    mkdir -p "${DATASET_OUT_DIR}"

    if [[ -f "${SRC}" ]]; then
        mv "${SRC}" "${DEST_PATH}"
        log "${LOGFILE}" "Output moved to ${DEST_PATH}"
    else
        log "${LOGFILE}" "WARNING: Output file not found"
    fi
}

# ------------------------------------------------------------------
# Prepare base directories
# ------------------------------------------------------------------
mkdir -p "${BASE_OUT_DIR}"
mkdir -p "${BASE_LOG_DIR}"

# ------------------------------------------------------------------
# Optional: permanent signal run (not from filesystem)
# ------------------------------------------------------------------
SIGNAL_LOG="${BASE_LOG_DIR}/signal_${TIMESTAMP_GLOBAL}.log"
run_dataset "signal" "${SIGNAL_LOG}"

# ------------------------------------------------------------------
# Loop over dataset folders
# ------------------------------------------------------------------
for DATASET_PATH in "${DATASET_BASE_DIR}"/*; do
    [[ -d "${DATASET_PATH}" ]] || continue

    DATASET=$(basename "${DATASET_PATH}")
    LOGFILE="${BASE_LOG_DIR}/${DATASET}_${TIMESTAMP_GLOBAL}.log"

    run_dataset "${DATASET}" "${LOGFILE}"
done

echo "All datasets processed (check ${BASE_LOG_DIR} for logs)"


#echo "Starting signal files simulation"

# Run for the signal files
#run_python "$SIGNAL"
#transfer_file "$SIGNAL"

#echo "Starting background files simulation"

# Now for the Background files
#run_python "$BACKGROUND"
#transfer_file "$BACKGROUND"

#rm -f test.slcio output.slcio

#echo "Finished simulation"


# Command that I used to copy the child folders from 250-SetA

# Create the target directory if it doesn’t exist
#mkdir -p "/afs/desy.de/user/b/bortolet/code/tomaz-example/output_files/"

# Find only the first‑level directories and recreate them in the target
#find "/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/" -mindepth 1 -maxdepth 1 -type d -exec bash -c '
#    src="$1"
#    dst="/afs/desy.de/user/b/bortolet/code/tomaz-example/output_files/$(basename "$src")"
#    mkdir -p "$dst"
#' _ {} \;