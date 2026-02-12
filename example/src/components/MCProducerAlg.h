#pragma once

#include "Gaudi/Algorithm.h"
#include "edm4hep/MCParticleCollection.h"

#include "k4FWCore/DataHandle.h"

#include "TLorentzVector.h"
#include "TFile.h"
#include "TTree.h"
#include <vector>
#include <string>


class MCProducerAlg : public Gaudi::Algorithm {
public:
  MCProducerAlg(const std::string& name, ISvcLocator* svcLoc);
  StatusCode execute(const EventContext&) const override;

  StatusCode initialize() override;
  StatusCode finalize() override;  

  //write to tree
  void fillEvent() const; // call once per event

  // Helper method to add an MC particle
  void addMCParticle(float pt, float eta, float phi, float e,
                     int pdgId, int status, int motherPdgId) const;
  void addMCParticle(const TLorentzVector& p4,
                     int pdgId, int status, int motherPdgId) const;

  // MC Truth
  mutable int nMCParticles;
  mutable std::vector<float> mc_pt;
  mutable std::vector<float> mc_eta;
  mutable std::vector<float> mc_phi;
  mutable std::vector<float> mc_e;
  mutable std::vector<int> mc_pdgId;
  mutable std::vector<int> mc_status;
  mutable std::vector<int> mc_motherPdgId;

private:

  mutable DataHandle<edm4hep::MCParticleCollection> m_mcParticleCollHandle{
    "MCParticleColl", Gaudi::DataHandle::Reader, this};

  //tree related
  TFile* outFile;
  TTree* tree;

  void setupBranches();

};
