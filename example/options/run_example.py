from k4FWCore import IOSvc
from k4MarlinWrapper.io_helpers import IOHandlerHelper
from Configurables import MarlinProcessorWrapper, MCConsumerAlg, MarlinProcessorWrapper, Lcio2EDM4hepTool#MCProducerAlg
from Gaudi.Configuration import *
from Gaudi.Configuration import ApplicationMgr

# ----------------------------------------------------------------------
# Input importing
# ----------------------------------------------------------------------
import os
import re
import json
from pathlib import Path
from typing import List, Iterable, Union, Literal

import pandas as pd


# Append the CSV folder and file name
csv_path = "/afs/desy.de/user/b/bortolet/code/tomaz-example/scripts/process_id.csv"
df = pd.read_csv(csv_path)
df["file_list"] = df["file_list"].apply(json.loads)

def collect_files(
    root_dir: str | os.PathLike,
    process_id: str,
    file_type: Literal["root", "slcio"] = "slcio",
    max_files: int | None = None,
) -> tuple[List[str], int]:
    """
    Recursively collect files of a given type under ``root_dir``
    matching a specific process_id and polarization eL.pR.

    Returns
    -------
    files : list[str]
        List of file paths
    n_files : int
        Number of collected files
    """
    base_path = Path(root_dir).expanduser().resolve()

    if not base_path.is_dir():
        raise NotADirectoryError(f"The supplied path is not a directory: {base_path}")

    pattern = f"*.{file_type}"
    files: List[str] = []

    for p in sorted(base_path.rglob(pattern)):
        if not p.is_file():
            continue

        name = p.name

        # polarization filter
        if "eL.pR" not in name:
            continue

        # process ID filter (e.g. I402003)
        if f".I{process_id}." not in name:
            continue

        files.append(str(p))

        if max_files is not None and len(files) >= max_files:
            break

    return files, len(files)

def collect_signal_files(
    root_dir: str | os.PathLike,
    file_type: Literal["root", "slcio"] = "root",
    max_files: int | None = None,
) -> List[str]:
    """
    Recursively collect files of a given type under ``root_dir``.

    Parameters
    ----------
    root_dir : str or Path-like
        The top-level directory to start the search from.
    file_type : {"root", "slcio"}
        File type to search for.
    max_files : int or None
        Maximum number of files to collect. If None, collect ALL files.

    Returns
    -------
    List[str]
        A list of file paths as strings.
    """
    base_path = Path(root_dir).expanduser().resolve()

    if not base_path.is_dir():
        raise NotADirectoryError(f"The supplied path is not a directory: {base_path}")

    pattern = f"*.{file_type}"
    files: List[str] = []

    for p in sorted(base_path.rglob(pattern)):
        if p.is_file():
            files.append(str(p))
            if max_files is not None and len(files) >= max_files:
                break

    return files

def validate_file_counts(
    csv_df: pd.DataFrame,
    root_dir: str,
):
    """
    Validate that the number of collected files per process_id
    matches the expected n_files from the CSV.
    """
    mismatches = []
    print("Begging Validation")
    for _, row in csv_df.iterrows():
        print(row)
        pid = row["process_id"]
        expected_n = int(row["n_files"])

        files, found_n = collect_files(
            root_dir=root_dir,
            process_id=pid,
        )
        print(found_n)
        if found_n != expected_n:
            mismatches.append(
                (pid, expected_n, found_n)
            )

    return mismatches

import argparse

def add_process_arguments(
    parser: argparse.ArgumentParser,
    process_ids: list[str],
):
    """
    Adds --IXXXXXX flags to the parser, one per process_id.
    """
    for pid in process_ids:
        parser.add_argument(
            f"--{pid}",
            action="store_true",
            default=False,
            help=f"Run simulation for process {pid}",
        )


def choose_dataset_from_args(
    args: argparse.Namespace,
    signal_name: str = "signal",
) -> str:
    """
    Determine dataset folder name from argparse arguments.

    Parameters
    ----------
    args : argparse.Namespace
        Parsed argparse options.
    signal_name : str
        Name of the permanent signal flag.

    Returns
    -------
    str
        Dataset name (folder name).

    Raises
    ------
    ValueError
        If no or multiple dataset flags are enabled.
    """
    arg_dict = vars(args)

    # 1) Special case: signal
    if arg_dict.get(signal_name, False):
        return signal_name

    # 2) Find other enabled dataset flags
    true_keys = [
        k for k, v in arg_dict.items()
        if isinstance(v, bool) and v is True and k != signal_name
    ]

    if not true_keys:
        raise ValueError("No dataset option selected")

    if len(true_keys) > 1:
        raise ValueError(
            f"Multiple dataset options selected: {true_keys}. "
            "Please choose only one."
        )

    return true_keys[0]


# ----------------------------------------------------------------------
# Custom arguments
# ----------------------------------------------------------------------
from k4FWCore.parseArgs import parser

# Arguments to choose the type of input files for signal, background and test.
parser.add_argument("--signal", action="store_true", help="Signal files simulation", default=False)
parser.add_argument("--test", action="store_true", help="Reduces the number of events to 1", default=False)
parser.add_argument("--validate", action="store_true", help="Checks if the process_id's are present", default=False)

def list_child_folders(parent_dir: str | Path) -> list[str]:
    p = Path(parent_dir)
    return sorted([d.name for d in p.iterdir() if d.is_dir()])

# This is the input folder where all the files are located
slcio_folder = "/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/"

def add_process_arguments(
    parser: argparse.ArgumentParser,
    process_ids: list[str],
):
    """
    Adds --IXXXXXX flags to the parser, one per process_id.
    """
    print("Valid arguments:")
    for pid in process_ids:

        parser.add_argument(
            f"--{pid}",
            action="store_true",
            default=False,
            help=f"Run simulation for process {pid}",
        )
        print(f"Added Argument: --{pid}")

# Add all processes that are presents in the process_id.csv file
process_ids = sorted(df["process_id"].astype(str).unique())
add_process_arguments(parser, process_ids)

# This makes the parser arguments functional
my_opts = parser.parse_known_args()[0]

# This validade to check if all the process_id have the same value as the process_id.csv
if my_opts.validate:
    mismatches = validate_file_counts(
    csv_df=df,
    root_dir=slcio_folder,
)
    if not mismatches:
        print("✅ All process_id file counts match the CSV.")
    else:
        print("❌ File count mismatches found:")
        for pid, expected, found in mismatches:
            print(f"{pid}: expected {expected}, found {found}")



# ----------------------------------------------------------------------
# io_svc code
# ----------------------------------------------------------------------

io_svc = IOSvc("IOSvc")

# List of algorithms to be used
algs = []

# ----------------------------------------------------------------------
# Signal Files
# ----------------------------------------------------------------------

# The ROOT files sit in “…/tomaz-example/input_files”
parent_dir = "../input_files/"

# Get the 12 file paths
source_list = collect_signal_files(parent_dir,
                    file_type="root"
 )

io_svc.Input = source_list

# ----------------------------------------------------------------------
# Background Files
# ----------------------------------------------------------------------


io = IOHandlerHelper(algs, io_svc)


# If the argument is for the test background files
if not my_opts.signal:

    print("Background Files Choosen.")

    # Replace this with the path to your top‑level folder
    # Get the process id from the input argument
    pid = choose_dataset_from_args(my_opts)
    # Get the number of files for this specific process id
    mask = df["process_id"] == int(pid)
    n_files = df.loc[mask, "n_files"].iloc[0]

    try:

        # Collect LCIO files
        slcio_files = df.loc[mask, "file_list"].iloc[0]
        size = len(slcio_files)
        #slcio_files, size = collect_files(slcio_folder, process_id=pid, file_type="slcio")
        print(f"Found {len(slcio_files)} SLCIO file(s) for an expected total of {n_files}.")
        assert size == n_files
        io_svc.Input = []

        # --- LCIO input ---
        io.add_reader(slcio_files)  # This uses LcioEvent internally if .slcio

        # --- Marlin processing ---
        myProc = MarlinProcessorWrapper("Output_DST")
        myProc.ProcessorType = "LCIOOutputProcessor"
        myProc.Parameters = {
             "LCIOOutputFile": ["test.slcio"],
             "LCIOWriteMode": ["WRITE_NEW"]
        }
        algs.append(myProc)

        # --- LCIO output ---
        lcio_writer = io.add_lcio_writer("LCIOWriter")
        lcio_writer.Parameters = {
            "LCIOOutputFile": ["output.slcio"],
            "LCIOWriteMode": ["WRITE_NEW"]
        }

        # ------------------------------------------------------------
        # 3. EDM4hep output (ONLY selected collections)
        # ------------------------------------------------------------
        # (Optional) attach LCIO → EDM4hep converter to this processor
        lcio2edm = Lcio2EDM4hepTool("Lcio2EDM4hepTool")
        lcio2edm.collNameMapping = {
            "MCParticles": "MCParticles",
            "PandoraPFOs": "PandoraPFOs"
        }
        lcio2edm.convertAll = False  # convert only listed collections
        myProc.Lcio2EDM4hepTool = lcio2edm


        # --- Finalize & run ---
        io.finalize_converters()  # If no conversion needed, this just finalizes

    except Exception as e:
        print(f"Error: {e}")

# ----------------------------------------------------------------------
# key4hep code
# ----------------------------------------------------------------------


collections = ["PandoraPFOs", "EventHeader"]

io_svc.CollectionNames = collections

# create a MCConsumer instance
consumer = MCConsumerAlg("MCConsumer")
consumer.RecoParticleColl = "PandoraPFOs"

# Add consumer to my algorithms
algs.append(consumer)

events_simulated = 1_000_000
if my_opts.test:
    events_simulated = 1

ApplicationMgr(
    # provide list and order of algorithms
    TopAlg=algs,
    EvtSel="NONE",
    EvtMax=events_simulated,
    ExtSvc=[io_svc],
    OutputLevel=INFO
)
