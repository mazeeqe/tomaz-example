#pragma once

#include "Gaudi/Algorithm.h"
#include "Gaudi/Property.h"
#include "edm4hep/MCParticleCollection.h"
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

  // Tree variables
  mutable int m_pdg;
  mutable float m_px, m_py, m_pz;
};
