from Gaudi.Configuration import *
from Gaudi.Configuration import ApplicationMgr
from Configurables import PodioInput, MCProducerAlg, MCConsumerAlg
from Configurables import k4DataSvc

evtSvc = k4DataSvc('EventDataSvc')
evtSvc.inputs = ["/afs/desy.de/user/b/bortolet/code/tomaz-example/input_files/Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-00002.root"]

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
