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
      int particleID = reconstructedParticle.getPDG();
      if (particleID == 22) { // select gluons
          float energy = reconstructedParticle.getEnergy();
          auto momentum = reconstructedParticle.getMomentum();

          totalE  += energy;
          totalPx += momentum.x;
          totalPy += momentum.y;
          totalPz += momentum.z;

          info() << "Selected PDG=21: E=" << energy
                 << " px=" << momentum.x
                 << " py=" << momentum.y
                 << " pz=" << momentum.z
                 << endmsg;
      }
  }

  // Compute invariant mass if we found any gluons
  if (totalE > 0) {
      float mass2 = totalE*totalE - (totalPx*totalPx + totalPy*totalPy + totalPz*totalPz);
      float mass = (mass2 > 0) ? std::sqrt(mass2) : 0.0;

      info() << "Invariant mass of PDG=21 system: " << mass << " GeV" << endmsg;
  }

  return StatusCode::SUCCESS;
}

StatusCode MCConsumerAlg::finalize() {
  return Gaudi::Algorithm::finalize();
}
