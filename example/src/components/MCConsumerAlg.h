#pragma once

#include "Gaudi/Algorithm.h"
#include "Gaudi/Property.h"
#include "edm4hep/MCParticleCollection.h"
#include "edm4hep/ReconstructedParticleCollection.h" // Added include
#include "k4FWCore/DataHandle.h"

#include "TFile.h"
#include "TTree.h"

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

  DataHandle<edm4hep::ReconstructedParticleCollection> m_recoParticleCollHandle{
    "RecoParticleColl",
    Gaudi::DataHandle::Reader,
    this
  };
};
