from Gaudi.Configuration import *
from Gaudi.Configuration import ApplicationMgr
from Configurables import PodioInput, MCProducerAlg, MCConsumerAlg
from Configurables import k4DataSvc

import pathlib

# Path to the directory that contains this script
script_dir = pathlib.Path(__file__).resolve().parent

# Relative location of the input file (adjust as needed)
input_path = script_dir / ".." / "input_files" / "Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-00002.root"
input_path = input_path.resolve()   # optional: get the absolute path for downstream APIs

print(input_path)   # e.g. /full/path/to/tomaz-example/input_files/...

evtSvc = k4DataSvc('EventDataSvc')
evtSvc.inputs = [input_path]

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
    EvtMax=5,
    ExtSvc=[evtSvc],
    OutputLevel=INFO
)
