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

  // Variables to store in the tree
  mutable float m_invMass   = 0.0;
  mutable float m_recoilMass = 0.0;
  mutable float m_totalEnergy  = 0.0;

  // Muon variables
  mutable float m_muonEnergy_high = 0.0;
  mutable float m_muonEnergy_low = 0.0;
  mutable float m_px           = 0.0;
  mutable float m_py           = 0.0;
  mutable float m_pz           = 0.0;
  mutable float m_met          = 0.0; // missing transverse energy

  // Missing Energy and Momentum
  mutable float m_missingEnergy = 0.0;
  mutable float m_missingPx = 0.0;
  mutable float m_missingPy = 0.0;
  mutable float m_missingPz = 0.0;

  // Monte Carlo weights
  mutable float m_weight = 1.0;

  // Run-level metadata (set from Python)
  Gaudi::Property<int> m_numEventsGenerated{
    this, "NumEventsGenerated", 10000, "Number of generated events"
  };
  Gaudi::Property<double> m_crossSection{
    this, "CrossSection", 1.0, "Process cross-section [pb]"
  };
  Gaudi::Property<double> m_targetLuminosity{
    this, "TargetLuminosity", 1000.0, "Target luminosity [fb^-1]"
  };

  // Constant for the Recoil Mass
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
