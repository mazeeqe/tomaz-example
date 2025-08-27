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

  // Create ROOT file and TTree
  m_rootFile = new TFile("hist.root", "RECREATE");
  m_tree = new TTree("events", "Muon analysis");

  // Define branches

  // Mass Branches
  m_tree->Branch("invMass",   &m_invMass,   "invMass/F");
  m_tree->Branch("recoilMass",&m_recoilMass,"recoilMass/F");
  m_tree->Branch("totalEnergy",  &m_totalEnergy,  "totalEnergy/F");
  m_tree->Branch("px",           &m_px,           "px/F");
  m_tree->Branch("py",           &m_py,           "py/F");
  m_tree->Branch("pz",           &m_pz,           "pz/F");
  m_tree->Branch("met",          &m_met,          "met/F");

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

  // Default values
  m_invMass = 0.0;
  m_recoilMass = 0.0;
  m_totalEnergy = 0.0;
  m_px = m_py = m_pz = m_met = 0.0;

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

  // Total 4-momentum of the muon system
  TLorentzVector dimuon = p4_1 + p4_2;

  m_invMass = (p4_1 + p4_2).M();
  m_totalEnergy = dimuon.E();
  m_px          = dimuon.Px();
  m_py          = dimuon.Py();
  m_pz          = dimuon.Pz();
  m_met         = std::sqrt(m_px*m_px + m_py*m_py); // MET definition

  // Initial 4-momentum of e+e- system
  TLorentzVector initial(0, 0, 0, m_ecm);



  // Recoil 4-momentum
  TLorentzVector recoil = initial - dimuon;
  m_recoilMass = recoil.M();

  // Fill tree for this event
  if (m_tree) m_tree->Fill();



  info() << "Invariant mass of two highest-pt muons = "
          << m_invMass << " GeV" << endmsg;

  info() << "Recoil mass = " << m_recoilMass << " GeV" << std::endl;

  return StatusCode::SUCCESS;
  }

  StatusCode MCConsumerAlg::finalize() {
  // Write to Root file
    if (m_rootFile) {
    m_rootFile->cd();
    if (m_tree) m_tree->Write();
    m_rootFile->Close();
    delete m_rootFile;
    m_rootFile = nullptr;
  }


  return Gaudi::Algorithm::finalize();
}
