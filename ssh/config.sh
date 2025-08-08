
# config.sh

# ---------- Configuration ----------
DEFAULT_USER="bortolet"
DEFAULT_HOST="naf-ilc.desy.de"

# Path for syncing
SRC_DIR="/home/mazeeqe/Documents/mestrado/code/input_files"
DEST_DIR="/afs/desy.de/user/b/bortolet/code/"

# Setup Commands
SETUP_COMMANDS=(
    "cd code/k4-project-template"
    "source /cvmfs/sw.hsf.org/key4hep/setup.sh"
    "k4_local_repo"
)