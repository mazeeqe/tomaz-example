from Gaudi.Configuration import *
from Gaudi.Configuration import ApplicationMgr
from Configurables import PodioInput, MCProducerAlg, MCConsumerAlg
from Configurables import k4DataSvc

# ----------------------------------------------------------------------
# Input importing
# ----------------------------------------------------------------------
import re
from pathlib import Path
from typing import List, Iterable


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
                    include=range(1,13)
 )

background_list = root_file_paths(parent_dir,
                prefix="rv02-02-01.sv02-02.mILD_l5_o2_v02.E250-SetA.I500078.P4f_zznu_sl.eL.pR.n000_001.d_dst_00015656_"
)

#For some reason running 1 and 2 crashes but 1 by itself worked
# ----------------------------------------------------------------------
# key4hep code
# ----------------------------------------------------------------------

evtSvc = k4DataSvc('EventDataSvc')
evtSvc.inputs = source_list + background_list

# Input: PODIO .root file with MCParticles
podioinput = PodioInput("InputReader")

collections = ["PandoraPFOs", "PrimaryVertex", "PandoraClusters",
                "MarlinTrkTracks", "EventHeader", "MCParticlesSkimmed"]

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
    EvtMax=1000,
    ExtSvc=[evtSvc],
    OutputLevel=INFO
)
