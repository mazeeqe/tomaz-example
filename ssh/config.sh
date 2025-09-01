
# config.sh

# ---------- Configuration ----------
DEFAULT_USER="bortolet"
DEFAULT_HOST="naf-ilc.desy.de"

# Path for syncing
SRC_DIR="/home/mazeeqe/Documents/mestrado/code/tomaz-example"
DEST_DIR="/afs/desy.de/user/b/bortolet/code/"
LOCAL_OUTPUT_DIR="/home/mazeeqe/Documents/mestrado/code/"
REMOTE_OUTPUT_DIR="/afs/desy.de/user/b/bortolet/code/tomaz-example"

# Setup Commands
SETUP_COMMANDS=(
    "source /cvmfs/sw.hsf.org/key4hep/setup.sh -r 2025-01-28"
    "cd code/tomaz-example/"
    "source setup.sh"
    "cd build"
)

#remote to local
# rsync -avhP bortolet@naf-ilc.desy.de:/afs/desy.de/user/b/bortolet/code/tomaz-example /home/mazeeqe/Documents/mestrado/code/

#local to remote
# rsync -avhP /home/mazeeqe/Documents/mestrado/code/tomaz-example bortolet@naf-ilc.desy.de:/afs/desy.de/user/b/bortolet/code/