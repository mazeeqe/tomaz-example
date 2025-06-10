#include "MCConsumerAlg.h"

DECLARE_COMPONENT(MCConsumerAlg)

MCConsumerAlg::MCConsumerAlg(const std::string& name, ISvcLocator* svcLoc)
    : Gaudi::Algorithm(name, svcLoc) {
}

MCConsumerAlg::~MCConsumerAlg() = default;

StatusCode MCConsumerAlg::initialize() {
  StatusCode sc = Gaudi::Algorithm::initialize();
  if (!sc.isSuccess()) return sc;

  return StatusCode::SUCCESS;
}

StatusCode MCConsumerAlg::execute(const EventContext&) const {
  return StatusCode::SUCCESS;
}

StatusCode MCConsumerAlg::finalize() {
  return StatusCode::SUCCESS;
}
