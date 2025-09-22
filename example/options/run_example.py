from Gaudi.Configuration import *
from Gaudi.Configuration import ApplicationMgr
from Configurables import PodioInput, MCProducerAlg, MCConsumerAlg
from Configurables import k4DataSvc

# ----------------------------------------------------------------------
# Input importing
# ----------------------------------------------------------------------
import re
from pathlib import Path
from typing import List, Iterable, Union


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


# The ROOT files sit in “…/tomaz-example/input_files”
parent_dir = "../input_files"

# Get the 12 file paths
source_list = root_file_paths(parent_dir,
                    include=range(2,13)
 )

def build_file_paths_regex(
    parent_dir: Union[str, Path],
    pattern: Union[str, List[str]],
    *,
    ignore_case: bool = False,
) -> List[str]:
    """
    Scan ``parent_dir`` with ``pathlib`` and return a list of *strings* that
    contain the absolute paths of files whose names match the supplied
    regular‑expression pattern(s).

    Parameters
    ----------
    parent_dir : str | pathlib.Path
        Directory that holds the target files.

    pattern : str | List[str]
        One regex pattern or a list of patterns applied to the filename
        (``Path.name``).  Example that matches the five ROOT files you listed::

            r"^rv02-02-01\\.sv02-02\\.mILD_l5_o2_v02\\.E250-SetA\\.I500078\\."
            r"P4f_zznu_sl\\.eL\\.pR\\.n000_\\d{3}\\.d_dst_00015656_\\d+\\.root$"

    ignore_case : bool, default=False
        If True, compile the regexes with ``re.IGNORECASE``.

    Returns
    -------
    List[str]
        Absolute path strings for each matching file, sorted alphabetically
        by filename.

    Example
    -------
    >>> regex = (
    ...     r"^rv02-02-01\\.sv02-02\\.mILD_l5_o2_v02\\.E250-SetA\\.I500078\\."
    ...     r"P4f_zznu_sl\\.eL\\.pR\\.n000_\\d{3}\\.d_dst_00015656_\\d+\\.root$"
    ... )
    >>> build_file_paths_regex("/my/data", regex)
    ['/my/data/rv02-02-01.sv02-02.mILD_l5_o2_v02.E250-SetA.I500078.'
     'P4f_zznu_sl.eL.pR.n000_001.d_dst_00015656_146.root',
     '/my/data/rv02-02-01.sv02-02.mILD_l5_o2_v02.E250-SetA.I500078.'
     'P4f_zznu_sl.eL.pR.n000_002.d_dst_00015656_70.root', …]
    """
    # --------------------------------------------------------------
    # Normalise the directory path
    parent_path = Path(parent_dir).expanduser().resolve()

    if not parent_path.is_dir():
        raise NotADirectoryError(f"'{parent_path}' is not a valid directory.")

    # --------------------------------------------------------------
    # Compile regex(es)
    if isinstance(pattern, str):
        patterns = [pattern]
    else:
        patterns = list(pattern)

    flags = re.IGNORECASE if ignore_case else 0
    compiled = [re.compile(p, flags) for p in patterns]

    # --------------------------------------------------------------
    # Collect matching files (non‑recursive – replace with rglob() for recursion)
    matched_strings: List[str] = []
    for entry in sorted(parent_path.iterdir()):   # deterministic order
        if not entry.is_file():
            continue

        if any(regex.search(entry.name) for regex in compiled):
            # Convert the Path object to its absolute string representation
            matched_strings.append(str(entry))

    return matched_strings

my_regex = (
        r"^rv02-02-01\.sv02-02\.mILD_l5_o2_v02\.E250-SetA\.I500078\."
        r"P4f_zznu_sl\.eL\.pR\.n000_\d{3}\.d_dst_00015656_\d+\.root$"
    )


background_list = build_file_paths_regex(parent_dir, my_regex)

#For some reason running 1 and 2 crashes but 1 by itself worked
# ----------------------------------------------------------------------
# key4hep code
# ----------------------------------------------------------------------

evtSvc = k4DataSvc('EventDataSvc')
evtSvc.inputs = background_list

# Input: PODIO .root file with MCParticles
podioinput = PodioInput("InputReader")

collections = ["PandoraPFOs", "EventHeader", "MCParticlesSkimmed"]

podioinput.collections = collections

# create a MCProducer instance
producer = MCProducerAlg("MCProducer")
producer.MCParticleColl = "MCParticlesSkimmed"
producer.OutputLevel = INFO

# create a MCConsumer instance
consumer = MCConsumerAlg("MCConsumer")
consumer.RecoParticleColl = "PandoraPFOs"

ApplicationMgr(
    # provide list and order of algorithms
    TopAlg=[podioinput, producer, consumer],
    EvtSel="NONE",
    EvtMax=10000,
    ExtSvc=[evtSvc],
    OutputLevel=INFO
)
