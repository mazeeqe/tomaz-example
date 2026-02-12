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
  mutable TTree* m_metaTree = nullptr;

  // Event Variables
  mutable int m_nGenerated = 0;
  mutable int m_nSelected  = 0;


  // Global Variables
  mutable int nCharged = 0;
  mutable int nChargedNonMuon = 0;
  mutable int nTracks = 0;
  mutable int nTracksNonMuon = 0;
  mutable int totalCharge = 0;
  mutable float sumPtChargedNonMuon = 0.0;
  mutable int nRecoTracks = 0;
  
  // Non-Muon variables
  mutable float visibleEnergy = 0.0;
  mutable float visiblePx = 0.0;
  mutable float visiblePy = 0.0;
  mutable float visiblePz = 0.0;
  mutable float visiblePt = 0.0;

  // Variables to store in the tree
  mutable float m_invMass   = 0.0;
  mutable float m_recoilMass = 0.0;
  mutable float m_totalEnergy  = 0.0;

  // Individual Muon variables
  // Muon 1 (leading)
  mutable float m_mu1_E= 0.0;
  mutable float m_mu1_px= 0.0;
  mutable float m_mu1_py= 0.0;
  mutable float m_mu1_pz= 0.0;
  mutable float m_mu1_pt= 0.0;
  mutable int   m_mu1_charge= 0;

  // Muon 2 (subleading)
  mutable float m_mu2_E= 0.0;
  mutable float m_mu2_px= 0.0;
  mutable float m_mu2_py= 0.0;
  mutable float m_mu2_pz= 0.0;
  mutable float m_mu2_pt= 0.0;
  mutable int   m_mu2_charge= 0;


  // Muon Pair variables
  mutable float m_px           = 0.0;
  mutable float m_py           = 0.0;
  mutable float m_pz           = 0.0;
  mutable float m_transverse_momentum = 0.0;
  
  // Missing Energy and Momentum
  mutable float m_missingEnergy = 0.0;
  mutable float m_missingPx = 0.0;
  mutable float m_missingPy = 0.0;
  mutable float m_missingPz = 0.0;
  mutable float m_met          = 0.0; // missing transverse energy


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
