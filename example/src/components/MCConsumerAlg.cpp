#include "MCConsumerAlg.h"

#include <cmath>
#include <algorithm>
#include <vector>
#include "TLorentzVector.h"
#include "TParameter.h"

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
  m_metaTree = new TTree("Metadata", "Sample metadata");




  // Define branches

  // Event Variables
  m_metaTree->Branch("nGenerated", &m_nGenerated, "nGenerated/I");
  m_metaTree->Branch("nSelected",  &m_nSelected,  "nSelected/I");


  // Global Variables
  m_tree->Branch("nCharged", &nCharged, "nCharged/I");
  m_tree->Branch("nChargedNonMuon", &nChargedNonMuon, "nChargedNonMuon/I");
  m_tree->Branch("nTracks", &nTracks, "nTracks/I");
  m_tree->Branch("nTracksNonMuon", &nTracksNonMuon, "nTracksNonMuon/I");
  m_tree->Branch("totalCharge", &totalCharge, "totalCharge/I");
  m_tree->Branch("sumPtChargedNonMuon", &sumPtChargedNonMuon, "sumPtChargedNonMuon/I");
  m_tree->Branch("nRecoTracks", &nRecoTracks, "nRecoTracks/I");

  // Non-Muon variables
  m_tree->Branch("visibleEnergy",  &visibleEnergy,  "visibleEnergy/F");
  m_tree->Branch("visiblePx",  &visiblePx,  "visiblePx/F");
  m_tree->Branch("visiblePy",  &visiblePy,  "visiblePy/F");
  m_tree->Branch("visiblePz",  &visiblePz,  "visiblePz/F");
  m_tree->Branch("visiblePt",  &visiblePt,  "visiblePt/F");

  // Mass Branches
  m_tree->Branch("invMass",   &m_invMass,   "invMass/F");
  m_tree->Branch("recoilMass",&m_recoilMass,"recoilMass/F");
  m_tree->Branch("totalEnergy",  &m_totalEnergy,  "totalEnergy/F");

  // Individual Muon variables
  // Muon 1 (leading)
  m_tree->Branch("mu1_E",      &m_mu1_E,      "mu1_E/F");
  m_tree->Branch("mu1_px",     &m_mu1_px,     "mu1_px/F");
  m_tree->Branch("mu1_py",     &m_mu1_py,     "mu1_py/F");
  m_tree->Branch("mu1_pz",     &m_mu1_pz,     "mu1_pz/F");
  m_tree->Branch("mu1_pt",     &m_mu1_pt,     "mu1_pt/F");
  m_tree->Branch("mu1_charge",&m_mu1_charge,"mu1_charge/I");

  // Muon 2 (subleading)
  m_tree->Branch("mu2_E",      &m_mu2_E,      "mu2_E/F");
  m_tree->Branch("mu2_px",     &m_mu2_px,     "mu2_px/F");
  m_tree->Branch("mu2_py",     &m_mu2_py,     "mu2_py/F");
  m_tree->Branch("mu2_pz",     &m_mu2_pz,     "mu2_pz/F");
  m_tree->Branch("mu2_pt",     &m_mu2_pt,     "mu2_pt/F");
  m_tree->Branch("mu2_charge",&m_mu2_charge,"mu2_charge/I");



  // Muon pair variables
  m_tree->Branch("dimuon_px",     &m_px,                   "dimuon_px/F");
  m_tree->Branch("dimuon_py",     &m_py,                   "dimuon_py/F");
  m_tree->Branch("dimuon_pz",     &m_pz,                   "dimuon_pz/F");
  m_tree->Branch("dimuon_pt",     &m_transverse_momentum,  "dimuon_pt/F");


  // New branches for missing energy
  m_tree->Branch("missingEnergy", &m_missingEnergy, "missingEnergy/F");
  m_tree->Branch("missingPx",     &m_missingPx,     "missingPx/F");
  m_tree->Branch("missingPy",     &m_missingPy,     "missingPy/F");
  m_tree->Branch("missingPz",     &m_missingPz,     "missingPz/F");
  m_tree->Branch("met",          &m_met,          "met/F");

  return StatusCode::SUCCESS;
}



StatusCode MCConsumerAlg::execute(const EventContext&) const {
  const auto* recoColl = m_recoParticleCollHandle.get();
  // Count the number of generated events
  ++m_nGenerated;
  // Reset values each event
  m_invMass = m_recoilMass = m_totalEnergy = 0.0;
  m_px = m_py = m_pz = m_met = 0.0;
  m_missingEnergy = m_missingPx = m_missingPy = m_missingPz = 0.0;

  // --- Loop over ALL particles to compute total event sums ---
  float sumE  = 0.0;
  float sumPx = 0.0, sumPy = 0.0, sumPz = 0.0;

  struct ParticleData {
      float E;
      float px, py, pz;
      float pt2;
      int charge;
  };


  std::vector<ParticleData> muons;
  nCharged = 0;
  nChargedNonMuon = 0;

  nTracks = 0;
  nTracksNonMuon = 0;

  totalCharge = 0;
  nRecoTracks = 0;
  sumPtChargedNonMuon = 0.0;
  // Select muons
  for (const auto& reconstructedParticle : *recoColl) {

      // Enegy and Momentum for each particle
      sumE  += reconstructedParticle.getEnergy();
      auto p = reconstructedParticle.getMomentum();
      sumPx += p.x;
      sumPy += p.y;
      sumPz += p.z;

      totalCharge += reconstructedParticle.getCharge();

      if (reconstructedParticle.getCharge() != 0) {
          ++nCharged;
          if (std::abs(reconstructedParticle.getPDG()) != 13) {
              ++nChargedNonMuon;
          }
      }


      if (reconstructedParticle.getCharge() != 0 &&
          std::abs(reconstructedParticle.getPDG()) != 13) {

          auto pp = reconstructedParticle.getMomentum();
          sumPtChargedNonMuon += std::sqrt(pp.x*pp.x + pp.y*pp.y);
      }



      const auto& tracks = reconstructedParticle.getTracks();
      nRecoTracks += tracks.size();
      

      for (const auto& track : tracks ) {
     	 ++nTracks;
     	 if (std::abs(reconstructedParticle.getPDG()) != 13) {
          ++nTracksNonMuon;
     	 }
      }


      // For the Muons
      int pdg = reconstructedParticle.getPDG();
      if (std::abs(pdg) == 13) {
          auto muon = reconstructedParticle.getMomentum();
          float E  = reconstructedParticle.getEnergy();
          float px = muon.x;
          float py = muon.y;
          float pz = muon.z;
          float pt2 = px*px + py*py;

          int charge = reconstructedParticle.getCharge();

          muons.push_back({E, px, py, pz, pt2, charge});



          info() << "Muon candidate PDG=" << pdg
          //       << " E=" << E
          //       << " px=" << px
          //       << " py=" << py
          //       << " pz=" << pz
	 	 << "charge= " << charge 
                 << " pt2=" << pt2 << endmsg;
      }
  }

  // Initial 4-momentum at e+e- collider
  float initE  = m_ecm;
  float initPx = 0.0;
  float initPy = 0.0;
  float initPz = 0.0;

  // Non-Muon variable
  visibleEnergy = sumE;
  visiblePx = sumPx;
  visiblePy = sumPy;
  visiblePz = sumPz;
  visiblePt = std::sqrt(sumPx*sumPx + sumPy*sumPy);

  // Missing energy and momentum
  m_missingEnergy = initE  - sumE;
  m_missingPx     = initPx - sumPx;
  m_missingPy     = initPy - sumPy;
  m_missingPz     = initPz - sumPz;
  m_met         = std::sqrt(m_missingPx*m_missingPx + m_missingPy*m_missingPy); // MET definition

  // Need at least two muons
  if (muons.size() != 2) {
      info() << "More or less than two muons found in event." << endmsg;
      return StatusCode::SUCCESS;
  }
  // Count the number of selected event, two muon pairs of opposite charge only
  ++m_nSelected;
  // Take the two muons
  auto& mu1 = muons[0];
  auto& mu2 = muons[1];

  // Muons should be of oposite charge
  if (mu1.charge * mu2.charge >= 0) {
    // same-sign or undefined charge
    return StatusCode::SUCCESS;
  }

  // Calculate the Invariant Mass
  TLorentzVector p4_1, p4_2;
  p4_1.SetPxPyPzE(mu1.px, mu1.py, mu1.pz, mu1.E);
  p4_2.SetPxPyPzE(mu2.px, mu2.py, mu2.pz, mu2.E);

  // Ensure muon 1 is leading pT
  if (p4_2.Pt() > p4_1.Pt()) {
      std::swap(p4_1, p4_2);
      std::swap(mu1, mu2);
  }

  // ---- Save individual muon kinematics ----

  // Muon 1
  m_mu1_E      = p4_1.E();
  m_mu1_px     = p4_1.Px();
  m_mu1_py     = p4_1.Py();
  m_mu1_pz     = p4_1.Pz();
  m_mu1_pt     = p4_1.Pt();
  m_mu1_charge = mu1.charge;

  // Muon 2
  m_mu2_E      = p4_2.E();
  m_mu2_px     = p4_2.Px();
  m_mu2_py     = p4_2.Py();
  m_mu2_pz     = p4_2.Pz();
  m_mu2_pt     = p4_2.Pt();
  m_mu2_charge = mu2.charge;


  // Total 4-momentum of the muon system
  TLorentzVector dimuon = p4_1 + p4_2;

  m_invMass = (p4_1 + p4_2).M();
  m_totalEnergy = dimuon.E();
  m_px          = dimuon.Px();
  m_py          = dimuon.Py();
  m_pz          = dimuon.Pz();
  m_transverse_momentum = std::sqrt(m_px*m_px + m_py*m_py);

  // Initial 4-momentum of e+e- system
  TLorentzVector initial(0, 0, 0, m_ecm);



  // Recoil 4-momentum
  TLorentzVector recoil = initial - dimuon;
  m_recoilMass = recoil.M();

  // Fill tree for this event
  if (m_tree) m_tree->Fill();



  //info() << "Invariant mass of two highest-pt muons = "
  //       << m_invMass << " GeV" << endmsg;

  //info() << "Recoil mass = " << m_recoilMass << " GeV" << std::endl;

  return StatusCode::SUCCESS;
  }

  StatusCode MCConsumerAlg::finalize() {

  info() << "Total generated events: " << m_nGenerated << endmsg;
  info() << "Total selected events : " << m_nSelected  << endmsg;

  // Write to Root file
    if (m_rootFile) {
    m_rootFile->cd();


    // Fill metadata tree FIRST
    if (m_metaTree) {
      m_metaTree->Fill();
      m_metaTree->Write();
    } 
    if (m_tree) {
	    m_tree->Write();
	    }

    m_rootFile->Close();
    delete m_rootFile;
    m_rootFile = nullptr;
  }


  return Gaudi::Algorithm::finalize();
}
