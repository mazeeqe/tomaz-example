#include "MCConsumerAlg.h"

#include <cmath>
#include <algorithm>
#include <vector>
#include "TLorentzVector.h"

DECLARE_COMPONENT(MCConsumerAlg)

MCConsumerAlg::MCConsumerAlg(const std::string& name, ISvcLocator* svcLoc)
    : Gaudi::Algorithm(name, svcLoc) {
  declareProperty("RecoParticleColl", m_recoParticleCollHandle, "RecoParticle collection");
}

MCConsumerAlg::~MCConsumerAlg() = default;

StatusCode MCConsumerAlg::initialize() {
  StatusCode sc = Gaudi::Algorithm::initialize();
  if (!sc.isSuccess()) return sc;

  // Create ROOT file and histogram
  m_rootFile = new TFile("hist.root", "RECREATE");
  m_h_mumu = new TH1F("h_mumu", "Invariant Mass of #mu#mu; M_{#mu#mu} [GeV]; Events", 
                      100, 0, 200);

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

  // Calculate the Invariant Mass
  TLorentzVector p4_1, p4_2;
  p4_1.SetPxPyPzE(mu1.px, mu1.py, mu1.pz, mu1.E);
  p4_2.SetPxPyPzE(mu2.px, mu2.py, mu2.pz, mu2.E);

  double invMass = (p4_1 + p4_2).M();

  // Fill histogram
  if (m_h_mumu) m_h_mumu->Fill(invMass);


  info() << "Invariant mass of two highest-pt muons = "
         << invMass << " GeV" << endmsg;

  return StatusCode::SUCCESS;
}

StatusCode MCConsumerAlg::finalize() {
  // Write to Root file
    if (m_rootFile) {
    m_rootFile->cd();
    if (m_h_mumu) m_h_mumu->Write();
    m_rootFile->Close();
    delete m_rootFile;
    m_rootFile = nullptr;
  }

  return Gaudi::Algorithm::finalize();
}
