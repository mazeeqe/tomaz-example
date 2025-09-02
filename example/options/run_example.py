from Gaudi.Configuration import *
from Gaudi.Configuration import ApplicationMgr
from Configurables import PodioInput, MCProducerAlg, MCConsumerAlg
from Configurables import k4DataSvc

# ----------------------------------------------------------------------
# Input importing
# ----------------------------------------------------------------------
from pathlib import Path
from typing import List

def root_file_paths(
    parent_folder: str | Path,
    start: int = 1,
    stop: int = 12,
    prefix: str = "Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-",
    suffix: str = ".root",
    pad: int = 5,
    absolute: bool = True
) -> List[str]:
    """
    Construct full file paths for files named like
    Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-00X.root
    that reside in ``parent_folder``.

    Parameters
    ----------
    parent_folder : str or Path
        The directory that contains the ROOT files.
    start, stop : int
        Index range (inclusive).  Use start=1 for “01”.
    prefix, suffix : str
        Fixed parts of the filename.
    pad : int
        Number of digits for zero‑padding (2 → 01,02,…).
    absolute : bool, default True
        If True, return absolute paths; otherwise return paths
        relative to ``parent_folder``.

    Returns
    -------
    List[str]
        A list of file paths ready to be opened.
    """
    parent = Path(parent_folder)

    paths: List[str] = []
    for i in range(start, stop + 1):
        idx = f"{i:0{pad}d}"                 # e.g. 1 → "01"
        filename = f"{prefix}{idx}{suffix}" # full filename
        file_path = parent / filename

        # Optionally resolve to an absolute path
        if absolute:
            file_path = file_path.resolve()

        paths.append(str(file_path))

    return paths



# The ROOT files sit in “…/tomaz-example/input_files”
parent_dir = "../../input_files"

# Get the 12 file paths
file_list = root_file_paths(parent_dir, start=1, stop=2)

# ----------------------------------------------------------------------
# key4hep code
# ----------------------------------------------------------------------

evtSvc = k4DataSvc('EventDataSvc')
evtSvc.inputs = file_list

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
