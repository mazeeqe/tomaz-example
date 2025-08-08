# Copyright (c) 2020-2024 Key4hep-Project.
#
# This file is part of Key4hep.
# See https://key4hep.github.io/key4hep-doc/ for further info.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Nao colocar acentos ou letras fora do normal

from Gaudi.Configuration import INFO
from Gaudi.Configuration import *
from k4FWCore import IOSvc
from k4FWCore import ApplicationMgr
from Configurables import SelectorAlg


input_file = "/afs/desy.de/user/b/bortolet/code/k4-project-template/k4ProjectTemplate/options/input_files/Dirac-Dst-E250-e2e2h_inv.eL.pR_bg-00002.root"


io_svc = IOSvc("IOSvc")

io_svc.Input = input_file

io_svc.CollectionNames = ["PandoraPFOs", "PrimaryVertex", "PandoraClusters", "MarlinTrkTracks", "EventHeader", "MCParticlesSkimmed", "MCParticles", "SimTrackerHits"]


alg = SelectorAlg(
        "Selector",
        InputParticles="MCParticles",
        InputHits="SimTrackerHits",
        Output="SelectedParticles",
)

ApplicationMgr(TopAlg=[alg],
               EvtSel="INFO",
               EvtMax=5,
               ExtSvc=[io_svc],
               OutputLevel=DEBUG,
               )
