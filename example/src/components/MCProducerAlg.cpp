#include "MCProducerAlg.h"

DECLARE_COMPONENT(MCProducerAlg)

MCProducerAlg::MCProducerAlg(const std::string& name, ISvcLocator* svcLoc)
    : Gaudi::Algorithm(name, svcLoc) {
  declareProperty("MCParticleColl", m_mcParticleCollHandle,
                  "MC Particle collection");

  std::string filename = "output_tree.root";
  outFile = new TFile(filename.c_str(), "RECREATE");
  tree = new TTree("events", "Higgs to Invisible Analysis Tree");
  setupBranches();    
}

StatusCode MCProducerAlg::execute(const EventContext& event) const {
  const auto* mcParticleColl = m_mcParticleCollHandle.get();

  // MC particles
  for (const auto& mc : *mcParticleColl) {
    auto parents = mc.getParents();
    int parentPDG;
    if (!parents.empty()) {
      const auto& parent = parents[0];  // if you just want the first parent
      parentPDG = parent.getPDG();
    } else {
      parentPDG = 0;
    }

    TLorentzVector p4;
    auto mom = mc.getMomentum();
    p4.SetPxPyPzE(mom.x, mom.y, mom.z, mc.getEnergy());
    addMCParticle(p4, mc.getPDG(), mc.getSimulatorStatus(), parentPDG);
  }


  return StatusCode::SUCCESS;
}

StatusCode MCProducerAlg::initialize() {
  return StatusCode::SUCCESS;
}

StatusCode MCProducerAlg::finalize() {
  return StatusCode::SUCCESS;
}

void MCProducerAlg::addMCParticle(const TLorentzVector& p4, int pdgId, int status,
                              int motherPdgId) const {
  addMCParticle(p4.Pt(), p4.Eta(), p4.Phi(), p4.E(), pdgId, status,
                motherPdgId);
}

void MCProducerAlg::addMCParticle(float pt, float eta, float phi, float e,
                              int pdgId, int status, int motherPdgId) const {
  mc_pt.push_back(pt);
  mc_eta.push_back(eta);
  mc_phi.push_back(phi);
  mc_e.push_back(e);
  mc_pdgId.push_back(pdgId);
  mc_status.push_back(status);
  mc_motherPdgId.push_back(motherPdgId);
  nMCParticles = mc_pt.size();
}

void MCProducerAlg::setupBranches() {
  // MC truth
  tree->Branch("nMCParticles", &nMCParticles, "nMCParticles/I");
  tree->Branch("mc_pt", &mc_pt);
  tree->Branch("mc_eta", &mc_eta);
  tree->Branch("mc_phi", &mc_phi);
  tree->Branch("mc_e", &mc_e);
  tree->Branch("mc_pdgId", &mc_pdgId);
  tree->Branch("mc_status", &mc_status);
  tree->Branch("mc_motherPdgId", &mc_motherPdgId);
}

