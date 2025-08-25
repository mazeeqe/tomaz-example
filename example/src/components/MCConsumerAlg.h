#pragma once

#include "Gaudi/Algorithm.h"
#include "Gaudi/Property.h"
#include "edm4hep/MCParticleCollection.h"
#include "edm4hep/ReconstructedParticleCollection.h" // Added include
#include "k4FWCore/DataHandle.h"

#include "TFile.h"
#include "TTree.h"
#include "TH1F.h"

class MCConsumerAlg : public Gaudi::Algorithm {
public:
  MCConsumerAlg(const std::string& name, ISvcLocator* svcLoc);
  ~MCConsumerAlg();

  StatusCode initialize() override;
  StatusCode execute(const EventContext&) const override;
  StatusCode finalize() override;

private:
  mutable TFile* m_rootFile = nullptr;
  mutable TTree* m_tree = nullptr;
  mutable TH1F* m_h_mumu = nullptr; // Invariant mass histogram
  mutable TH1F* m_h_recoil = nullptr; // Recoil mass histogram

  // Variables to store in the tree
  mutable float m_invMass   = 0.0;
  mutable float m_recoilMass = 0.0;

  Gaudi::Property<double> m_ecm{
    this, "CollisionEnergy", 250.0, "Center-of-mass energy [GeV]"
  };

  // I had to add a mutable at the beggining
  mutable DataHandle<edm4hep::ReconstructedParticleCollection> m_recoParticleCollHandle{
    "RecoParticleColl",
    Gaudi::DataHandle::Reader,
    this
  };
};
