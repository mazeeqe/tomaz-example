#!/usr/bin/env bash
set -u
set -o pipefail
# ⚠️ No exit, no set -e (SSH-safe)

# File Options
SIGNAL="signal"


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
CSV_FILE="../scripts/process_id.csv"
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

run_signal() {
    local LOGFILE="$1"

    log "${LOGFILE}" "=============================================="
    log "${LOGFILE}" "Starting SIGNAL simulation"

    tmp_log=$(mktemp)
    echo "▶ Running SIGNAL simulation" >> "${tmp_log}"

    "${COMMAND}" "${SCRIPT_PATH}" "--signal" >> "${tmp_log}" 2>&1
    RUN_STATUS=$?

    {
        head -n 1000 "${tmp_log}"
        echo "… (log trimmed) …"
        tail -n 50 "${tmp_log}"
    } >> "${LOGFILE}"

    rm -f "${tmp_log}"

    if (( RUN_STATUS != 0 )); then
        log "${LOGFILE}" "ERROR: Signal simulation failed (exit code ${RUN_STATUS})"
        return
    fi

    log "${LOGFILE}" "Signal simulation finished successfully"

    rm -f test.slcio output.slcio
    log "${LOGFILE}" "Deleted slcio files"

    local SIGNAL_OUT_DIR="${BASE_OUT_DIR}/signal"
    local DEST_FILE="signal_${TIMESTAMP_GLOBAL}_hist.root"
    local DEST_PATH="${SIGNAL_OUT_DIR}/${DEST_FILE}"

    mkdir -p "${SIGNAL_OUT_DIR}"

    if [[ -f "${SRC}" ]]; then
        mv "${SRC}" "${DEST_PATH}"
        log "${LOGFILE}" "Signal output moved to ${DEST_PATH}"
    else
        log "${LOGFILE}" "WARNING: Signal output file not found"
    fi
}


run_dataset() {
    local CSV_FILE="$1"
    local LOGFILE="$2"

    log "${LOGFILE}" "=============================================="
    log "${LOGFILE}" "Reading process IDs from: ${CSV_FILE}"

    # Skip header, read first column (process_id)
    tail -n +2 "${CSV_FILE}" | cut -d',' -f1 | while IFS= read -r PROCESS_ID; do
        [[ -z "${PROCESS_ID}" ]] && continue

        log "${LOGFILE}" "----------------------------------------------"
        log "${LOGFILE}" "Starting process_id: ${PROCESS_ID}"

        tmp_log=$(mktemp)
        echo "▶ Running simulation for process_id: ${PROCESS_ID}" >> "${tmp_log}"

        "${COMMAND}" "${SCRIPT_PATH}" "--${PROCESS_ID}" >> "${tmp_log}" 2>&1
        RUN_STATUS=$?

        {
            head -n 1000 "${tmp_log}"
            echo "… (log trimmed) …"
            tail -n 50 "${tmp_log}"
        } >> "${LOGFILE}"

        rm -f "${tmp_log}"

        if (( RUN_STATUS != 0 )); then
            log "${LOGFILE}" "ERROR: Simulation failed for ${PROCESS_ID} (exit code ${RUN_STATUS})"
            continue
        fi

        log "${LOGFILE}" "Simulation finished successfully for ${PROCESS_ID}"

        rm -f test.slcio output.slcio
        log "${LOGFILE}" "Deleted slcio files"

        # ---- Move output ------------------------------------------
        local DATASET_OUT_DIR="${BASE_OUT_DIR}/${PROCESS_ID}"
        local DEST_FILE="${PROCESS_ID}_${TIMESTAMP_GLOBAL}_hist.root"
        local DEST_PATH="${DATASET_OUT_DIR}/${DEST_FILE}"

        mkdir -p "${DATASET_OUT_DIR}"

        if [[ -f "${SRC}" ]]; then
            mv "${SRC}" "${DEST_PATH}"
            log "${LOGFILE}" "Output moved to ${DEST_PATH}"
        else
            log "${LOGFILE}" "WARNING: Output file not found for ${PROCESS_ID}"
        fi
    done
}


# ------------------------------------------------------------------
# Prepare base directories
# ------------------------------------------------------------------
mkdir -p "${BASE_OUT_DIR}"
mkdir -p "${BASE_LOG_DIR}"

# ------------------------------------------------------------------
# Optional: permanent signal run (not from filesystem)
# ------------------------------------------------------------------

# Signal first
SIGNAL_LOG="${BASE_LOG_DIR}/signal_${TIMESTAMP_GLOBAL}.log"
run_signal "${SIGNAL_LOG}"

# Background (all process_id)
BG_LOG="${BASE_LOG_DIR}/background_${TIMESTAMP_GLOBAL}.log"
run_dataset "${CSV_FILE}" "${BG_LOG}"

echo "All simulations finished (check ${BASE_LOG_DIR})"


echo "All datasets processed (check ${BASE_LOG_DIR} for logs)"

cleanup() {
    rm -f test.slcio output.slcio
}

trap cleanup EXIT


# Command that I used to copy the child folders from 250-SetA

# Create the target directory if it doesn’t exist
#mkdir -p "/afs/desy.de/user/b/bortolet/code/tomaz-example/output_files/"

# Find only the first‑level directories and recreate them in the target
#find "/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/" -mindepth 1 -maxdepth 1 -type d -exec bash -c '
#    src="$1"
#    dst="/afs/desy.de/user/b/bortolet/code/tomaz-example/output_files/$(basename "$src")"
#    mkdir -p "$dst"
#' _ {} \;
