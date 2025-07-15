from Gaudi.Configuration import *
from Gaudi.Configuration import ApplicationMgr
from Configurables import PodioInput, MCProducerAlg, MCConsumerAlg
from Configurables import k4DataSvc

evtSvc = k4DataSvc('EventDataSvc')
evtSvc.inputs = ["/afs/cern.ch/user/c/chensel/ILD/lcio_edm4hep/edm4hep/Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-00001.root"]

# Input: PODIO .root file with MCParticles
podioinput = PodioInput("InputReader")
podioinput.collections = ["PandoraPFOs", "PrimaryVertex", "PandoraClusters", "MarlinTrkTracks", "EventHeader", "MCParticlesSkimmed"]

# create a MCProducer instance
producer = MCProducerAlg("MCProducer")
producer.MCParticleColl = "MCParticlesSkimmed"
producer.OutputLevel = INFO

# create a MCConsumer instance
consumer = MCConsumerAlg("MCConsumer")

ApplicationMgr(
    # provide list and order of algorithms
    TopAlg=[podioinput, producer, consumer],
    EvtSel="NONE",
    EvtMax=5,
    ExtSvc=[evtSvc],
    OutputLevel=INFO
)
