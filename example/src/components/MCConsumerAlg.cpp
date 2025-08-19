#include "MCConsumerAlg.h"

DECLARE_COMPONENT(MCConsumerAlg)

MCConsumerAlg::MCConsumerAlg(const std::string& name, ISvcLocator* svcLoc)
    : Gaudi::Algorithm(name, svcLoc) {
  declareProperty("RecoParticleColl", m_recoParticleCollHandle, "RecoParticle collection");
}

MCConsumerAlg::~MCConsumerAlg() = default;

StatusCode MCConsumerAlg::initialize() {
  StatusCode sc = Gaudi::Algorithm::initialize();
  if (!sc.isSuccess()) return sc;

  return StatusCode::SUCCESS;
}

StatusCode MCConsumerAlg::execute(const EventContext&) const {
  const auto* recoColl = m_recoParticleCollHandle.get();
  for (const auto& reconstructedParticle : *recoColl) {
      float energy = reconstructedParticle.getEnergy();
      int particleID = reconstructedParticle.getPDG();
      
      
      // Print out the values
      info() << "ReconstructedParticle: Energy = " << energy
             << " GeV, PDG ID = " << particleID << endmsg;
  }

  return StatusCode::SUCCESS;
}

StatusCode MCConsumerAlg::finalize() {
  return Gaudi::Algorithm::finalize();
}
