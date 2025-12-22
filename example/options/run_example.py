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
from pathlib import Path
from typing import List, Iterable, Union, Literal


def collect_files(
    root_dir: str | os.PathLike,
    file_type: Literal["root", "slcio"] = "root",
    max_files: int = 10,
) -> List[str]:
    """
    Recursively collect files of a given type under ``root_dir``.

    Parameters
    ----------
    root_dir : str or Path-like
        The top-level directory to start the search from.
    file_type : {"root", "slcio"}
        File type to search for.
    max_files : int
        Maximum number of files to collect.

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

    for p in base_path.rglob(pattern):
        if p.is_file():
            files.append(str(p))
            if len(files) >= max_files:
                break

    return files

def root_file_paths(
    parent_folder: str | Path,
    *,
    prefix: str = "Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-",
    suffix: str = ".root",
    absolute: bool = True,
    include: Iterable[int] | None = None,
) -> List[str]:
    """
    Build a list of ROOT‑file paths for files whose names look like

        {prefix}{number}{suffix}

    where *number* can be any integer (e.g. 70, 146, 00123).  The function
    discovers the files that actually exist, extracts the numeric part,
    sorts them numerically, and returns the full paths.

    Parameters
    ----------
    parent_folder : str | Path
        Directory containing the ROOT files.
    prefix, suffix : str
        Fixed text surrounding the numeric identifier.
    absolute : bool, default True
        Return absolute paths when ``True``; otherwise return paths
        relative to ``parent_folder``.
    include : iterable of int | None, optional
        If supplied, only files whose numeric identifier is in this
        collection are kept.  Useful when you want a subset of the
        discovered files.

    Returns
    -------
    List[str]
        Sorted list of file paths (as strings) ready for opening.
    """

    parent = Path(parent_folder)

    # Build a regex that captures the number between prefix and suffix.
    # Example pattern: ^Dirac-Dst-E250-e2e2h_inv\.eL\.pR_bg-(\d+)\\.root$
    escaped_prefix = re.escape(prefix)
    escaped_suffix = re.escape(suffix)
    pattern = re.compile(rf"^{escaped_prefix}(\d+){escaped_suffix}$")

    matched: List[tuple[int, Path]] = []

    for entry in parent.iterdir():
        if not entry.is_file():
            continue
        m = pattern.match(entry.name)
        if m:
            num = int(m.group(1))          # numeric part as int
            if include is None or num in include:
                matched.append((num, entry))

    # Sort by the extracted integer (numeric order, not lexical)
    matched.sort(key=lambda pair: pair[0])

    # Resolve to absolute paths if requested
    result = [
        str(p.resolve() if absolute else p)
        for _, p in matched
    ]

    return result


import argparse


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

def list_child_folders(parent_dir: str | Path) -> list[str]:
    p = Path(parent_dir)
    return sorted([d.name for d in p.iterdir() if d.is_dir()])

slcio_folder = "/pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/250-SetA/"

child_folders = list_child_folders(slcio_folder)
if not child_folders:
    raise RuntimeError("No child folders found")

available_backgrounds = []
print("Available folders:")
for i, c in enumerate(child_folders):
    parser.add_argument(f"--{c}", action="store_true", help="Background files simulation for {c}", default=False)
    print(f"Added {c} folder into argument --{c}.")
    available_backgrounds.append(c)


my_opts = parser.parse_known_args()[0]
# ----------------------------------------------------------------------
# Randomize the seed
# ----------------------------------------------------------------------

import random
from Configurables import UniqueIDGenSvc
uidgen_svc = UniqueIDGenSvc()
uidgen_svc.Seed = random.randint(0, 2**32 - 1)

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
source_list = root_file_paths(parent_dir,
                    include=range(1,13)
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
    dataset_name = choose_dataset_from_args(my_opts)
    input_dir = slcio_folder + dataset_name
    print(input_dir)

    try:

        # Collect LCIO files
        slcio_files = collect_files(input_dir, file_type="slcio", max_files=10000)
        print(f"Found {len(slcio_files)} SLCIO file(s) in {sub_folder}")
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

ApplicationMgr(
    # provide list and order of algorithms
    TopAlg=algs,
    EvtSel="NONE",
    EvtMax=100,
    ExtSvc=[io_svc],
    OutputLevel=INFO
)
