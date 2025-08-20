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

  struct ParticleData {
      float E;
      float px, py, pz;
      float pt2;
  };

  std::vector<ParticleData> muons;

  // Select muons
  for (const auto& reconstructedParticle : *recoColl) {
      int pdg = reconstructedParticle.getPDG();
      if (std::abs(pdg) == 13) {
          auto p = reconstructedParticle.getMomentum();
          float E  = reconstructedParticle.getEnergy();
          float px = p.x;
          float py = p.y;
          float pz = p.z;
          float pt2 = px*px + py*py;

          muons.push_back({E, px, py, pz, pt2});

          info() << "Muon candidate PDG=" << pdg
                 << " E=" << E
                 << " px=" << px
                 << " py=" << py
                 << " pz=" << pz
                 << " pt2=" << pt2 << endmsg;
      }
  }

  // Need at least two muons
  if (muons.size() < 2) {
      info() << "Less than two muons found in event." << endmsg;
      return StatusCode::SUCCESS;
  }

  // Sort descending by pt2
  std::sort(muons.begin(), muons.end(),
            [](const ParticleData& a, const ParticleData& b) {
                return a.pt2 > b.pt2;
            });

  // Take top two
  auto& mu1 = muons[0];
  auto& mu2 = muons[1];

  // Combined 4-vector
  float E  = mu1.E  + mu2.E;
  float px = mu1.px + mu2.px;
  float py = mu1.py + mu2.py;
  float pz = mu1.pz + mu2.pz;

  float mass2 = E*E - (px*px + py*py + pz*pz);
  float mass = (mass2 > 0) ? std::sqrt(mass2) : 0.0;

  info() << "Invariant mass of two highest-pt muons = "
         << mass << " GeV" << endmsg;

  return StatusCode::SUCCESS;
}

StatusCode MCConsumerAlg::finalize() {
  return Gaudi::Algorithm::finalize();
}
